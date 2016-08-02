require 'rails_helper'

feature 'like', js: true do
  let(:user) { create :user, :admin }
  let(:post) { create :post, :with_user }
  let(:users) do
    {
      user: create(:user, :user),
      moderator: create(:user, :moderator),
      admin: create(:user, :admin)
    }
  end

  shared_examples 'create like' do |role|
    scenario "correct case with role '#{role}'" do
      login_as users[role.to_sym]
      post = create :post, :with_user
      visit "/posts/#{post.id}"
      expect(page).to have_link 'Like'
      click_on 'Like'
      expect(page).to have_link 'Dislike'
      expect(page.find('header').text).to match "Post ##{post.id}"
    end
  end

  shared_examples 'should not create second like on post' do |role|
    scenario "correct case with role '#{role}'" do
      login_as users[role.to_sym]
      post = create :post, :with_user
      like = create :like, user: users[role.to_sym], post: post
      visit "/posts/#{post.id}"
      expect(page).not_to have_link 'Like'
    end
  end  

  shared_examples 'should not create like on own post' do |role|
    scenario "correct case with role '#{role}'" do
      login_as users[role.to_sym]
      post = create :post, author: users[role.to_sym]
      visit "/posts/#{post.id}"
      expect(page).not_to have_link 'Like'
    end
  end  

  context 'create like' do
    User.roles.keys.each { |role| it_behaves_like 'create like', role }
    User.roles.keys.each { |role| it_behaves_like 'should not create second like on post', role }
    User.roles.keys.each { |role| it_behaves_like 'should not create like on own post', role }
  end

  shared_examples 'delete like' do |role|
    scenario "correct case with role '#{role}'"  do
      login_as users[role.to_sym]
      post = create :post, :with_user
      like = create :like, user: users[role.to_sym], post: post
      visit "/posts/#{post.id}"
      expect(page).to have_link 'Dislike'
      click_on 'Dislike'
      expect(page).to have_link 'Like'
    end
  end

  context 'delete like' do
    User.roles.keys.each { |role| it_behaves_like 'delete like', role }

    scenario 'incorrect case' do
      login_as users[:admin]
      post = create :post, author: users[:admin]
      like = create :like, user: users[:user], post: post
      visit "/posts/#{post.id}"
      expect(page).not_to have_link 'Dislike'
    end
  end 

  context 'view like' do
    scenario 'correct case for admin' do
      login_as users[:admin]
      post = create :post, author: users[:user]
      like = create :like, user: users[:admin], post: post
      like = create :like, user: users[:moderator], post: post
      visit "/posts/#{post.id}"
      click_on post.likes.count.to_s
      expect(page.find('header').text).to match "Likes for Post ##{post.id}"
      expect(page.body).to match users[:admin].name
      expect(page.body).to match users[:moderator].name
      #post.likes.each { |like| expect(page).to have_link like.user.name }
      click_on users[:admin].name
      expect(page.body).to match users[:admin].email
      expect(page.body).to match users[:admin].role
    end

    scenario 'correct case for moderator' do
      login_as users[:moderator]
      post = create :post, author: users[:user]
      like = create :like, user: users[:moderator], post: post
      like = create :like, user: users[:admin], post: post
      visit "/posts/#{post.id}"
      click_on post.likes.count.to_s
      expect(page.find('header').text).to match "Likes for Post ##{post.id}"
      expect(page.body).to match users[:moderator].name
      expect(page.body).to match users[:admin].name
      click_on users[:admin].name
      expect(page.body).to match users[:admin].email
      expect(page.body).to match users[:admin].role
    end

    scenario 'correct case for user' do
      login_as users[:user]
      post = create :post, author: users[:admin]
      like = create :like, user: users[:user], post: post
      visit "/posts/#{post.id}"
      expect(page).not_to have_link post.likes.count.to_s
    end
  end
end
