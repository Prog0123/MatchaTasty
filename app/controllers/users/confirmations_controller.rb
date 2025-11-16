class Users::ConfirmationsController < Devise::ConfirmationsController
  def show
    # トークンで確認を試みる
    self.resource = resource_class.confirm_by_token(params[:confirmation_token])

    if resource.errors.empty?
      # 確認成功 - ログインしてTOPへ
      set_flash_message!(:notice, :confirmed) if is_navigational_format?
      sign_in(resource_name, resource)
      redirect_to root_path
    else
      # 確認失敗（既に確認済み、トークン無効など） - TOPへ
      redirect_to root_path, notice: "メールアドレスは既に登録済みです。"
    end
  end

  # GET /users/confirmation/new - 再送信ページ
  def new
    redirect_to root_path
  end

  # POST /users/confirmation - 再送信
  def create
    redirect_to root_path
  end
end
