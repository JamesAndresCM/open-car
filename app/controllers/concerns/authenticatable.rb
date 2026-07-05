module Authenticatable
  extend ActiveSupport::Concern

  PERMISSIONS_TTL = 5.minutes.to_i

  included do
    helper_method :current_user, :current_user_email, :logged_in?, :can?, :admin?
  end

  def authenticate!
    return if logged_in?
    redirect_to login_path, alert: t("auth.login_required")
  end

  def logged_in?
    current_claims.present?
  end

  def current_user
    current_claims
  end

  def current_user_email
    session[:current_user_email]
  end

  def can?(permission)
    current_permissions.include?(permission)
  end

  def admin?
    roles = session[:current_user_roles] || []
    (roles & ["admin", "superadmin"]).any?
  end

  def require_permission!(permission)
    return if can?(permission)
    redirect_to root_path, alert: t("auth.permission_denied")
  end

  private

  # Permisos frescos desde Ironiauth, cacheados en sesión por 5 minutos.
  def current_permissions
    @current_permissions ||= begin
      token = session[:ironiauth_token]
      return [] unless token

      cached_at = session[:permissions_cached_at].to_i
      if cached_at > 0 && Time.now.to_i - cached_at < PERMISSIONS_TTL
        return session[:ironiauth_permissions] || []
      end

      result = IroniauthClient.fetch_permissions(jwt: token)
      permissions = result.dig(:body, "permissions") || []
      session[:ironiauth_permissions] = permissions
      session[:permissions_cached_at] = Time.now.to_i
      permissions
    rescue
      []
    end
  end

  def current_claims
    @current_claims ||= begin
      token = session[:ironiauth_token]
      return nil unless token

      public_key = IroniauthClient.rsa_public_key
      payload, _header = JWT.decode(token, public_key, true, algorithms: [ "RS256" ])
      payload
    rescue JWT::ExpiredSignature
      session.delete(:ironiauth_token)
      session.delete(:ironiauth_permissions)
      session.delete(:permissions_cached_at)
      session.delete(:current_user_email)
      nil
    rescue JWT::DecodeError
      nil
    end
  end
end
