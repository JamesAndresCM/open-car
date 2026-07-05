require "net/http"
require "json"

class IroniauthClient
  BASE_URL    = ENV.fetch("IRONIAUTH_URL", "http://localhost:4000")
  API_KEY     = ENV.fetch("IRONIAUTH_API_KEY")
  COMPANY_UUID = ENV.fetch("IRONIAUTH_COMPANY_UUID")

  # Carga la clave pública RSA desde el endpoint JWKS de Ironiauth.
  # Se memoiza a nivel de clase para no hacer una request por cada decode de JWT.
  def self.rsa_public_key
    @rsa_public_key ||= begin
      uri = URI("#{BASE_URL}/.well-known/jwks.json")
      response = Net::HTTP.get(uri)
      jwks = JSON.parse(response)
      jwk = JWT::JWK.import(jwks["keys"].first)
      jwk.public_key
    end
  end

  def self.sign_in(email:, password:)
    post("/api/v1/sign_in", { email: email, password: password })
  end

  def self.sign_up(username:, email:, password:, password_confirmation:)
    post("/api/v1/sign_up", {
      user: { username: username, email: email, password: password, password_confirmation: password_confirmation }
    })
  end

  def self.fetch_permissions(jwt:)
    get("/api/v1/users/permissions", jwt: jwt)
  end

  def self.fetch_user_info(jwt:)
    get("/api/v1/users/me", jwt: jwt)
  end

  # URLs del Hosted UI de Ironiauth para redirigir el browser del usuario.
  def self.hosted_login_url(callback_url:)
    "#{BASE_URL}/login?#{URI.encode_www_form(company_uuid: COMPANY_UUID, redirect_uri: callback_url)}"
  end

  def self.hosted_register_url(callback_url:)
    "#{BASE_URL}/register?#{URI.encode_www_form(company_uuid: COMPANY_UUID, redirect_uri: callback_url)}"
  end

  def self.hosted_admin_url(callback_url:)
    "#{BASE_URL}/manage?#{URI.encode_www_form(company_uuid: COMPANY_UUID, redirect_uri: callback_url)}"
  end

  def self.hosted_logout_url(callback_url:)
    "#{BASE_URL}/manage/logout?#{URI.encode_www_form(redirect_uri: callback_url)}"
  end

  private

  def self.post(path, body)
    uri = URI("#{BASE_URL}#{path}")
    req = Net::HTTP::Post.new(uri.path, {
      "Content-Type" => "application/json",
      "Authorization" => "Bearer #{API_KEY}"
    })
    req.body = body.to_json
    respond(uri, req)
  end

  def self.get(path, jwt:)
    uri = URI("#{BASE_URL}#{path}")
    req = Net::HTTP::Get.new(uri.path, {
      "Authorization" => "Bearer #{jwt}"
    })
    respond(uri, req)
  end

  def self.respond(uri, req)
    res = Net::HTTP.new(uri.host, uri.port).request(req)
    { status: res.code.to_i, body: JSON.parse(res.body) }
  rescue => e
    { status: 503, body: { "error" => e.message } }
  end
end
