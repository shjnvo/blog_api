class ApplicationController < ActionController::API
  include Pagy::Backend
  before_action :require_user

  private
  
  def require_admin
    render json: { message: I18n.t('responce_message.not_permition') }, status: :forbidden unless current_user.admin?
  end

  def require_user
    render json: { message: I18n.t('responce_message.please_login') }, status: :unauthorized if current_user.blank? 
  end

  def current_user
    token = request.headers['Authentication'].presence
    decode = JwtService.decode token
    return if decode.blank?
    User.unlockeds.find_by(token: decode['user_token'])
  end
end
