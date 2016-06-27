class Comment < ActiveRecord::Base
  belongs_to :author, class_name: User
  belongs_to :post
  belongs_to :last_updated_by, class_name: User

  has_attached_file :file_attach, url: "/paperclip/#{Rails.env}/comment_attach/:id/:filename.:extension"
  do_not_validate_attachment_file_type :file_attach

  validates :author, :post, presence: true
  validates :content, presence: true, length: { in: 3..1024 }

  def last_actor
    last_updated_by ? last_updated_by : author
  end
end
