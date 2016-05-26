require 'rails_helper'

describe Post do
  context 'validation' do
    def post_not_valid(post, wrong_attr)
      expect(post.valid?).to be false
      expect(post.save).to be false
      expect(post.errors[wrong_attr]).not_to be_empty
    end

    def post_valid(post)
      expect(post.valid?).to be true
      expect(post.save).to be true
      expect(post.errors).to be_empty
    end

    describe 'on post' do
      it 'should not save post w/o author' do
	     post_not_valid Post.new(title: Faker::Lorem.sentence, content: Faker::Lorem.paragraph), :author
      end

      it 'should not save post w/o content' do
	     # post_not_valid Post.new(title: Faker::Lorem.sentence, :with_user), :content
       post_not_valid FactoryGirl.build(:post, :with_user, content: nil), :content
      end

      it 'should not save short post' do
        post_not_valid Post.new(title: Faker::Lorem.sentence, content: "a" * 5, author: create(:user)), :content
      end

      it 'should not save long post' do
        post_not_valid Post.new(title: Faker::Lorem.sentence, content: "a" * 2050, author: create(:user)), :content
      end

      it 'should save post w/minimal content' do
        post_valid Post.new(title: Faker::Lorem.sentence, content: "a" * 8, author: create(:user))
      end

      it 'should save post w/maximum content' do
        post_valid Post.new(title: Faker::Lorem.sentence, content: "a" * 2048, author: create(:user))
      end
      
      it 'should not save post w/o title' do
	     post_not_valid Post.new(content: Faker::Lorem.paragraph, author: create(:user)), :title
      end

      it 'should not save post w/short title' do
        post_not_valid Post.new(content: Faker::Lorem.paragraph, title: "aa", author: create(:user)), :title
      end

      it 'should not save post w/long title' do
        post_not_valid Post.new(content: Faker::Lorem.paragraph, title: "a" * 260, author: create(:user)), :title
      end

      it 'should save post w/minimal title' do
        post_valid Post.new(content: Faker::Lorem.paragraph, title: "aaa", author: create(:user))
      end

      it 'should save post w/maximum title' do
        post_valid Post.new(title: Faker::Lorem.sentence, content: "a" * 255, author: create(:user))
      end
    end
  end

  context 'association' do
    describe 'posts' do
      it 'should ' do
        
      end
    end
  end
  
  context 'method' do
    describe 'author of any role' do
      it 'should create post' do
        user = create :user, :user
        moderator = create :user, :moderator
        admin = create :user, :admin
        user_post = create :post, author: user
        moderator_post = FactoryGirl.create :post, author: moderator
        admin_post = create :post, author: admin
        expect(user_post.author_role).to eq ''
        expect(moderator_post.author_role).to eq 'moderator'
        expect(admin_post.author_role).to eq 'admin'
      end
    end
    
    describe 'posts' do
      it 'should return author name' do
        user = create :user, :user
        user_post = create :post, author: user
        expect(user_post.author_name).to eq user.name
      end
    end
  end
end 
