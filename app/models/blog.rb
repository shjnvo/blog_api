class Blog < ApplicationRecord
  include PgSearch::Model
  extend FriendlyId

  friendly_id :title, use: [:slugged]
  # TODO can search with vietnamese language
  pg_search_scope :search_by_title, against: :title

  belongs_to :creator, class_name: "User", foreign_key: :creator_id
  has_one :user_like_blog

  validates :title, :content, presence: true
  validates :title, uniqueness: true, length: { maximum: 50 }

  scope :publisheds, -> { where.not(published_at: nil) }

  after_validation :published, on: :create

  def unpublish!
    self.update(published_at: nil)
  end

  def published
    self.published_at = Time.zone.now
  end

  def should_generate_new_friendly_id?
    title_changed? || super
  end
end
