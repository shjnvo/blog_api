class User < ApplicationRecord
  include PgSearch::Model
  pg_search_scope :search_by_name_email, against: [:name, :email]

  has_secure_password :password, validations: false

  has_many :blogs, foreign_key: :creator_id

  validates :name, :email, :role, presence: true
  validates :name, length: { in: 5..50 }
  validates :password, length: { minimum: 6 }, on: :create
  validates :email, uniqueness: true, format: { with: URI::MailTo::EMAIL_REGEXP }
  validates :role, inclusion: { in: %w(admin user) }

  scope :lockeds, -> { where(locked: true) }
  scope :unlockeds, -> { where(locked: false) }

  def generate_token!
    loop do
      token = SecureRandom.hex
      unless User.exists?(token: token)
        self.update!(token: token)
        break
      end
    end

    token
  end

  def reset_token!
    self.update(token: nil)
  end

  def locked!
    self.update(locked: true, locked_at: Time.zone.now)
  end

  def unlock!
    self.update(locked: false, locked_at: nil)
  end

  def like_for(blog)
    user_like = UserLikeBlog.find_or_create_by(user: self, blog: blog)
    UserLikeBlog.increment_counter(:like_count, user_like.id)
  end

  def admin?
    role == 'admin'
  end

  def self.collection_for(user)
    return User.all if user.admin?
    User.unlockeds
  end
end
