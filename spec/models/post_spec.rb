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

    describe 'on post' do
      it 'should not save post w/o author' do
	    post_not_valid Post.new(title: Faker::Lorem.sentence, content: Faker::Lorem.paragraph), :author
      end
      it 'should not save post w/o content' do
	    post_not_valid Post.new(title: Faker::Lorem.sentence), :content
	    trait :with_user
      end
      it 'should not save short post' do
        post_not_valid Post.new(title: Faker::Lorem.sentence, content: "a" * 5), :content
        trait :with_user
      end
      it 'should not save long post' do
        post_not_valid Post.new(title: Faker::Lorem.sentence, content: "a" * 2050), :content
        trait :with_user
      end
      it 'should save post w/minimal content' do
        post_valid Post.new(title: Faker::Lorem.sentence, content: "a" * 8), :content
        trait :with_user
      end
      it 'should save post w/maximum content' do
        post_valid Post.new(title: Faker::Lorem.sentence, content: "a" * 2048), :content
        trait :with_user
      end
      
      it 'should not save post w/o title' do
	    post_not_valid Post.new(content: Faker::Lorem.paragraph)
      end
      it 'should not save post w/short title' do
        post_not_valid Post.new(content: Faker::Lorem.paragraph, title: "aa"), :title
        trait :with_user
      end
      it 'should not save post w/long title' do
        post_not_valid Post.new(title: Faker::Lorem.sentence, content: "a" * 260), :content
        trait :with_user
      end
      it 'should save post w/minimal title' do
        post_valid Post.new(title: Faker::Lorem.sentence, content: "aaa"), :content
        trait :with_user
      end
      it 'should save post w/maximum title' do
        post_valid Post.new(title: Faker::Lorem.sentence, content: "a" * 255), :content
        trait :with_user
      end
    end

  context 'association' do
    describe 'author of any role' do
      it 'should create post' do
        user = create :user, :user
        moderator = create :user, :moderator
        admin = create :user, :admin
        user_post = create :post, author: user
        moderator_post = create :post, author: moderator
        admin_post = create :post, author: admin
        expect(user_post.author_role).to eq ''
        expect(moderator_post.author_role).to eq 'moderator'
        expect(admin_post.author_role).to eq 'admin'
      end
    end
  
  context 'callback' do
    describe 'after_create_post' do
      it 'should send email' do
        expect { create :post }.to change { ActionMailer::Base.deliveries.count }.by 1
      end
    end
  end
end  