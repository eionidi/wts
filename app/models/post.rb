class Post < ActiveRecord::Base
  belongs_to :author, class_name: User

  has_attached_file :image,
                    styles: { index: '200x200>', show: '400x400>' },
                    url: "/paperclip/#{Rails.env}/post_image/:id/:style.:extension"
  validates_attachment_content_type :image, content_type: %r{\Aimage\/.*\Z}

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
