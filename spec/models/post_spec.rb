require 'rails_helper'

describe Post do
  context 'validation' do
    def user_not_valid(post, wrong_attr)
      expect(post.valid?).to be false
      expect(post.save).to be false
      expect(post.errors[wrong_attr]).not_to be_empty
    end

    def post_valid(post)
      expect(post.valid?).to be true
      expect(post.save).to be true
      expect(post.errors).to be_empty
    end

    describe 'on author' do
      it 'should not save post w/o author' do
	post_not_valid Post.new(title: Faker::Lorem.sentence, content: Faker::Lorem.paragraph), :author
      end
    end

  context 'association' do
    describe 'author of any role' do
      it 'should create post' do
        user = create(:user, :user, name: 'Vasya')
        moderator = create :user, :moderator
        admin = create :user, :admin
        user_post = create :post, author: user
        moderator_post = create(:post, author: moderator)
        admin_post = create :post, author: admin
      end
    end
  end
end
