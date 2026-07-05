class SessionsController < ApplicationController
  skip_before_action :authenticate!, raise: false

  # GET /login  →  redirige al Hosted UI de Ironiauth
  def new
    return redirect_to root_path if logged_in?

    redirect_to IroniauthClient.hosted_login_url(callback_url: auth_callback_url),
                allow_other_host: true
  end

  # GET /register  →  redirige al Hosted UI de Ironiauth (registro)
  def new_registration
    return redirect_to root_path if logged_in?

    redirect_to IroniauthClient.hosted_register_url(callback_url: auth_callback_url),
                allow_other_host: true
  end

  # GET /auth/callback?jwt=<token>
  # Ironiauth redirige aquí tras un login o registro exitoso.
  # Guarda el JWT en sesión y limpia la URL del historial con location.replace.
  def callback
    jwt = params[:jwt]

    if jwt.blank?
      redirect_to login_path, alert: t("auth.login_failed")
      return
    end

    session[:ironiauth_token] = jwt
    session.delete(:ironiauth_permissions)
    session.delete(:permissions_cached_at)

    user_info = IroniauthClient.fetch_user_info(jwt: jwt)
    session[:current_user_email] = user_info.dig(:body, "email")
    session[:current_user_roles] = user_info.dig(:body, "roles") || []

    # Renderizar página mínima que usa location.replace para
    # eliminar la URL con ?jwt= del historial del browser.
    render html: <<~HTML.html_safe, layout: false
      <!DOCTYPE html><html><head>
      <script>window.location.replace('/');</script>
      </head><body>Redirigiendo...</body></html>
    HTML
  end

  # DELETE /logout
  def destroy
    session.delete(:ironiauth_token)
    session.delete(:ironiauth_permissions)
    session.delete(:permissions_cached_at)
    session.delete(:current_user_email)
    session.delete(:current_user_roles)
    # Redirige por Ironiauth para limpiar la sesión del panel de admin (single sign-out)
    redirect_to IroniauthClient.hosted_logout_url(callback_url: root_url),
                allow_other_host: true
  end
end
