require 'rails_helper'

describe User do
  context 'validation' do
    def user_not_valid(user, wrong_attr)
      expect(user.valid?).to be false
      expect(user.save).to be false
      expect(user.errors[wrong_attr]).not_to be_empty
    end

    def user_valid(user)
      expect(user.valid?).to be true
      expect(user.save).to be true
      expect(user.errors).to be_empty
    end

    describe 'on email' do
      it 'should not save user w/o email' do
        user_not_valid User.new(name: Faker::Name.name), :email
      end
      it 'should not save user w/short email' do
        user_not_valid User.new(name: Faker::Name.name, email: 'a@a'), :email
      end
      it 'should not save user w/long email' do
        user_not_valid User.new(name: Faker::Name.name, email: "#{'a' * 255}@a.a"), :email
      end
      it 'should not save user w/wrong email' do
        user_not_valid User.new(name: Faker::Name.name, email: "a" * 10), :email
      end
      it 'should not save user w/exists email' do
        user = create :user
        user_not_valid User.new(name: Faker::Name.name, email: user.email), :email
      end
      it 'should save user w/minimal email' do
        user_valid User.new(name: Faker::Name.name, email: 'a@a.a')
      end
      it 'should save user w/maximum email' do
        user_valid User.new(name: Faker::Name.name, email: "#{'a' * 251}@a.a")
      end
    end
    
    describe 'user name' do
      it 'should not save user w/o name' do
        user_not_valid User.new(email: Faker::Internet.email, name: ""), :name
      end
    end	

	describe 'author name ' do
	  it 'should not save post w/o author' do
	    post_not_valid Post.new(name: Faker::Name.name), :author
      end
    end
  end
  
  context 'association' do
    describe 'posts' do
      it 'should return all created posts' do
        first_user = create :user
        another_user = create :user
        first_user_posts = Array.new(rand(1..10)) { create :post, author: first_user }
        second_user_posts = Array.new(rand(1..10)) { create :post, author: another_user }
        expect(first_user.posts.to_a).to eq first_user_posts
      end
    end
    
    describe 'posts author' do
    #пост может принадлежать только одному автору
    # у автора моет быть несколько постов
      #it { should belongs_to(:author) }
      #it 'should has only one author' do
      it {should has_one (:author)}
      end
    end
    
    describe 'author' do
      it { should have_many(:post) }
      end
    end
    
    describe 'author of any role' do
      it 'should create post' do
        user = create :user, role :{user: 1}
        moderator = create :user, role :{moderator: 2}
        admin = create :user, role :{admin: 3}
        user_post = Post.new { create :post, author: user }
        moderator_post = Post.new { create :post, author: moderator }
        admin_post = Post.new { create :post, author: admin }
      end
    end
  end  
  
  context 'callback' do
    describe 'after_create' do
      it 'should send email' do
        expect { create :user }.to change { ActionMailer::Base.deliveries.count }.by 1
      end
    end
  end

  context 'method' do
    it 'should return nil if posts empty' do
      user = create :user
      expect(user.last_post).to be nil
    end
    it "should return users's last post" do
      user = create :user
      posts = Array.new(rand(1..10)) { create :post, author: user }
      expect(user.last_post).to eq posts.last
    end
  end

