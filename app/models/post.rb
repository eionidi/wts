class Post < ActiveRecord::Base
  belongs_to :author, class_name: User

  validates :title, presence: true, length: { in: 3..255 }
  validates :content, presence: true, length: { in: 8..2048 }
  validates :author, presence: true

  def author_name
    author.name
  end

  def author_role
    return '' if author.user?
    author.role
  end
end
