class User < ActiveRecord::Base
  enum role: { user: 1, moderator: 2, admin: 3 }

  has_many :posts, foreign_key: :author_id, inverse_of: :author, dependent: :restrict_with_error

  validates :email, presence: true, uniqueness: true, format: { with: /\A[^@]+@[^@]+\z/ }, length: { in: 5..255 }
  validates :name, presence: true, length: { in: 3..255 }

  after_create :send_notification

  def last_post
    posts.order(created_at: :desc).first
  end

  private

  def send_notification
    # TODO: send notification to admin
    puts "TODO: send notification to admin"
  end
end
