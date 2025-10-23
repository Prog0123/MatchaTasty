class Users::OmniauthCallbacksController < Devise::OmniauthCallbacksController
  skip_before_action :verify_authenticity_token, only: :google_oauth2

  def google_oauth2
    Rails.logger.debug "=== OmniAuth Callback Started ==="
    Rails.logger.debug "Auth data present: #{request.env['omniauth.auth'].present?}"

    if request.env["omniauth.auth"].present?
      auth = request.env["omniauth.auth"]
      Rails.logger.debug "Provider: #{auth.provider}"
      Rails.logger.debug "UID: #{auth.uid}"
      Rails.logger.debug "Email: #{auth.info.email}"
      Rails.logger.debug "Name: #{auth.info.name}"

      @user = User.from_omniauth(auth)
      Rails.logger.debug "User created/found: #{@user.inspect}"
      Rails.logger.debug "User persisted?: #{@user.persisted?}"
      Rails.logger.debug "User errors: #{@user.errors.full_messages}" unless @user.persisted?

      if @user.persisted?
        sign_in_and_redirect @user, event: :authentication
        set_flash_message(:notice, :success, kind: "Google") if is_navigational_format?
      else
        session["devise.google_data"] = request.env["omniauth.auth"].except("extra")
        redirect_to new_user_registration_url, alert: @user.errors.full_messages.join("\n")
      end
    else
      Rails.logger.error "=== No omniauth.auth data found ==="
      redirect_to new_user_session_url, alert: "Googleでのログインに失敗しました（認証データなし）"
    end
  rescue StandardError => e
    Rails.logger.error "=== OmniAuth Error ==="
    Rails.logger.error e.message
    Rails.logger.error e.backtrace.join("\n")
    redirect_to new_user_session_url, alert: "認証エラー: #{e.message}"
  end

  def failure
    Rails.logger.error "=== OmniAuth Failure ==="
    Rails.logger.error "Error: #{params[:error]}"
    Rails.logger.error "Error description: #{params[:error_description]}"
    Rails.logger.error "Error reason: #{params[:error_reason]}"
    redirect_to new_user_session_url, alert: "Googleでのログインに失敗しました"
  end
end
