class Users::PasswordsController < Devise::PasswordsController
  def new
    super
  end

  def create
    self.resource = resource_class.send_reset_password_instructions(resource_params)
    yield resource if block_given?

    if successfully_sent?(resource)
      flash[:notice] = "パスワード再設定メールを送信しました。メールをご確認ください。"
      respond_with({}, location: after_sending_reset_password_instructions_path_for(resource_name))
    else
      flash.now[:alert] = "メールアドレスが見つかりません"
      respond_with(resource)
    end
  end

  def edit
    super
  end

  def update
    self.resource = resource_class.reset_password_by_token(resource_params)
    yield resource if block_given?

    if resource.errors.empty?
      resource.unlock_access! if unlockable?(resource)
      flash[:notice] = "パスワードを変更しました。"
      sign_in(resource_name, resource)
      respond_with resource, location: after_resetting_password_path_for(resource)
    else
      set_minimum_password_length
      respond_with resource
    end
  end

  protected

  def after_resetting_password_path_for(resource)
    root_path # パスワード変更後のリダイレクト先
  end

  def after_sending_reset_password_instructions_path_for(resource_name)
    new_user_session_path # メール送信後のリダイレクト先
  end
end
