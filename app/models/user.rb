class User < ActiveRecord::Base
  enum role: { user: 1, moderator: 2, admin: 3 }

  validates :email, presence: true, uniqueness: true, format: { with: /\A[^@]+@[^@]+\z/ }, length: { in: 5..255 }
  validates :name, presence: true, length: { in: 3..255 }
end
