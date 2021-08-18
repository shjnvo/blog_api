class UserLikeBlog < ApplicationRecord
  belongs_to :user
  belongs_to :blog, dependent: :destroy

  class << self
    def most_like_blog
      most_like_blog_id = UserLikeBlog.group(:blog_id).sum(:like_count).sort_by { |k,v| v }&.last&.first
      Blog.publisheds.find_by(id: most_like_blog_id)
    end

    def top_5_like_blog_for(user)
      blogs = UserLikeBlog.where(user: user).order(like_count: :desc).pluck(:blog_id).try(:first, 5)

      Blog.publisheds.joins(:user_like_blog).where(id: blogs).order(like_count: :desc)
    end
  end
end
