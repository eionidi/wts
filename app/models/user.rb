class User < ActiveRecord::Base
  devise :database_authenticatable, :registerable, :validatable

  enum role: { user: 1, moderator: 2, admin: 3 }

  has_many :posts, foreign_key: :author_id, inverse_of: :author, dependent: :restrict_with_error
  has_many :comments, foreign_key: :author_id, inverse_of: :author, dependent: :restrict_with_error
  has_many :likes, dependent: :restrict_with_error

  validates :email, presence: true, uniqueness: true, format: { with: /\A[^@]+@[^@]+\z/ }, length: { in: 5..255 }
  validates :name, presence: true, length: { in: 3..255 }

  after_create :send_notification

  def last_post
    posts.order(created_at: :desc).first
  end

  private

  def send_notification
    UsersMailer.new_user(self).deliver_now
  end
end
