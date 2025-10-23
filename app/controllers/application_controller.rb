class ApplicationController < ActionController::Base
  # 古いブラウザからのアクセスブロック
  allow_browser versions: :modern

  # Devise用のストロングパラメータ設定を追加
  before_action :configure_permitted_parameters, if: :devise_controller?
  helper_method :current_user

  protected

  def configure_permitted_parameters
    devise_parameter_sanitizer.permit(:sign_up, keys: [ :name ])
    devise_parameter_sanitizer.permit(:account_update, keys: [ :name ])
  end

  # Deviseのエラーメッセージを日本語化
  def after_sign_in_path_for(resource)
    stored_location_for(resource) || root_path
  end

  def after_sign_out_path_for(resource_or_scope)
    new_user_session_path
  end
end
