class V1::BlogsController < ApplicationController
  before_action :find_blog, except: [:index, :create, :top_5_blogs, :most_like_blog]
  before_action :edit_permition, only: [:update, :destroy, :unpublish]

  def index
    pagy, blogs = if params[:text_search].presence
                    pagy(Blog.publisheds.search_by_title(params[:text_search]))
                  else
                    pagy(Blog.publisheds)
                  end

    render json: { 
                    data: blogs, current_page: pagy.pages,
                    last_page: pagy.last,
                    most_like_blog: UserLikeBlog.most_like_blog,
                 }, status: :ok
  end

  def show
    render json: { data: @blog }, status: :ok
  end

  def most_like_blog
    blog = UserLikeBlog.most_like_blog
    render json: { data: blog }, status: :ok
  end

  def top_5_blogs
    blogs = UserLikeBlog.top_5_like_blog_for(current_user)
    render json: { data: blogs }, status: :ok
  end 

  def create
    blog = Blog.new(bolg_params)
    blog.creator = current_user
    if user.save
      render json: { message: I18n.t('responce_message.created', type: 'Blog'), user: user }, status: :created
    else
      render json: { message: blog.errors.messages }, status: :bad_request
    end
  end

  def update
    if @blog.update(blog_params)
      render json: { message: I18n.t('responce_message.updated', type: 'Blog') }, status: :ok
    else
      render json: { message: @blog.errors.messages }, status: :bad_request
    end
  end

  def destroy
    @blog.destroy
    render json: { message: I18n.t('responce_message.destroyed', type: 'Blog') }, status: :ok
  end

  def like
    current_user.like_for(@blog)
    render json: { message: I18n.t('responce_message.blog_liked') }, status: :ok
  end

  def unpublish
    @blog.unpublish!
    render json: { message: I18n.t('responce_message.blog_unpublish') }, status: :ok
  end

  private

  def blog_params
    params.permit(:title, :content)
  end

  def find_blog
    @blog = Blog.friendly.find(params[:id])
  rescue ActiveRecord::RecordNotFound
    render json: { message: I18n.t('responce_message.not_found', type: 'Blog') }, status: :bad_request
  end

  def edit_permition
    unless current_user.admin? || @blog.creator == current_user
      render json: { message: I18n.t('responce_message.not_permition') }, status: :forbidden
    end
  end
end
