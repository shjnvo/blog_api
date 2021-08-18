class V1::UsersController < ApplicationController
  before_action :find_user, except: [:index, :create, :search]
  before_action :require_admin, except: [:index, :search]

  def index
    pagy, users = if params[:text_search].presence
                    pagy(User.collection_for(current_user).search_by_name_email(params[:text_search]))
                  else
                    pagy(User.collection_for(current_user))
                  end

    render json: { data: users, current_page: pagy.pages }
  end

  def create
    user = User.new(user_params)
    if user.save
      render json: { message: I18n.t('responce_message.created', type: 'User'), user: user }, status: :created
    else
      render json: { message: user.errors.messages }, status: :bad_request
    end
  end

  def update
    if @user.update(user_params)
      render json: { message: I18n.t('responce_message.updated', type: 'User') }, status: :ok
    else
      render json: { message: @user.errors.messages }, status: :bad_request
    end
  end

  def destroy
    @user.destroy
    render json: { message: I18n.t('responce_message.destroyed', type: 'User') }, status: :ok
  end

  def lock
    @user.locked!
    render json: { message: I18n.t('responce_message.user_locked') }, status: :ok
  end

  def unlock
    @user.unlock!
    render json: { message: I18n.t('responce_message.user_unlock') }, status: :ok
  end

  private

  def user_params
    params.permit(:name, :email, :password, :role)
  end

  def find_user
    @user = User.find_by(id: params[:id])
    render json: { message: I18n.t('responce_message.not_found', type: 'User') }, status: :bad_request unless @user
  end
end
