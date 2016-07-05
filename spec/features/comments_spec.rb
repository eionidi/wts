require 'rails_helper'

feature 'comments', js: true do
  let(:user) { create :user, :admin }
  let(:post) { create :post, :with_user }
  let(:users) do
    {
      user: create(:user, :user),
      moderator: create(:user, :moderator),
      admin: create(:user, :admin)
    }
  end


  before(:each) { login_as user }

  shared_examples 'create comment' do |role|
    scenario "correct case with role '#{role}'" do
      login_as users[role.to_sym]
      post = create :post, :with_user
      visit "/posts/#{post.id}"
      expect(page).to have_link 'add comment'
      click_on 'add comment'
      expect(page).to have_field 'comment[content]'
      expect(page).to have_selector 'input[value="create"]'
      page.fill_in 'comment[content]', with: 'My first comment'
      find('input[value="create"]').click
      expect(page.find('header').text).to match "Post ##{post.id}"
      expect(page.body).to match 'My first comment'
    end
  end

  context 'create comment' do
    User.roles.keys.each { |role| it_behaves_like 'create comment', role }


  # context 'create comment' do
  #   scenario 'correct case for admin' do
  #     login_as create(:user, :admin)
  #     post = create :post, :with_user
  #     visit "/posts/#{post.id}"
  #     expect(page).to have_link 'add comment'
  #     click_on 'add comment'
  #     expect(page).to have_field 'comment[content]'
  #     expect(page).to have_selector 'input[value="create"]'
  #     page.fill_in 'comment[content]', with: 'My first comment'
  #     find('input[value="create"]').click
  #     expect(page.find('header').text).to match "Post ##{post.id}"
  #     expect(page.body).to match 'My first comment'
  #   end

  #   scenario 'correct case for user' do
  #     post = create :post, :with_user
  #     visit "/posts/#{post.id}"
  #     expect(page).to have_link 'add comment'
  #     click_on 'add comment'
  #     expect(page).to have_field 'comment[content]'
  #     expect(page).to have_selector 'input[value="create"]'
  #     page.fill_in 'comment[content]', with: 'My first comment'
  #     find('input[value="create"]').click
  #     expect(page.find('header').text).to match "Post ##{post.id}"
  #     expect(page.body).to match 'My first comment'
  #   end

  #   scenario 'correct case for moderator' do
  #     login_as create(:user, :moderator)
  #     post = create :post, :with_user
  #     visit "/posts/#{post.id}"
  #     expect(page).to have_link 'add comment'
  #     click_on 'add comment'
  #     expect(page).to have_field 'comment[content]'
  #     expect(page).to have_selector 'input[value="create"]'
  #     page.fill_in 'comment[content]', with: 'My first comment'
  #     find('input[value="create"]').click
  #     expect(page.find('header').text).to match "Post ##{post.id}"
  #     expect(page.body).to match 'My first comment'
  #   end

    scenario 'incorrect case' do
      login_as create(:user, :admin)
      post = create :post, :with_user
      visit "/posts/#{post.id}"
      expect(page).to have_link 'add comment'
      click_on 'add comment'
      expect(page).to have_field 'comment[content]'
      expect(page).to have_selector 'input[value="create"]'
      page.fill_in 'comment[content]', with: 'a'
      find('input[value="create"]').click
      expect(page.find('header').text).to match 'New comment'
      expect(page.find('.flash-error').text).not_to be_empty
    end
  end

  context 'delete comment' do
    scenario 'correct case for admin' do
      login_as create(:user, :admin)
      #post = create :post, :with_user
   	  comment = Comment.create(content: Faker::Lorem.paragraph, post: create(:post, :with_user))
   	  comment.errors.messages
      #comment = create :comment, :with_user
      visit "/posts/#{post.id}"
      #not found
      expect(page).to have_link comment.content 
      click_on comment.content
      expect(page.find('header').text).to eq "Comment ##{comment.id}"
      expect(page).to have_link 'delete'
      click_on 'delete'
      expect(page.find('header').text).to eq "Post ##{post.id}"
      expect(page.body).not_to match comment.content
    end

    scenario 'correct case for moderator' do
      login_as create(:user, :moderator)
      comment = create :comment, :with_user
      visit "/posts/#{post.id}"
      expect(page).to have_link comment.content 
      click_on comment.content
      expect(page.find('header').text).to eq "Post ##{post.id}"
      expect(page).not_to have_link 'delete'
    end

    scenario 'correct case for user' do
      login_as create(:user, :user)
      comment = create :comment, :with_user
      visit "/posts/#{post.id}"
      expect(page).to have_link comment.content 
      click_on comment.content
      expect(page.find('header').text).to eq "Post ##{post.id}"
      expect(page).not_to have_link 'delete'
    end
  end

  # shared_examples 'view comment' do
  #   scenario "correct case with role '#{role}'"
  # 	login_as users[role.to_sym]
  # 	post = create :post, :with_user
  #     comment = create :comment, :with_user
  #     visit "/posts/#{post.id}/comments/#{comment.id}" 
  #     expect(page.find('header').text).to eq "Comment ##{comment.id} on post ##{post.id}"
  #     expect(page.body).to match comment.content
  #   end
  # end

  # context 'view comment' do
  #   User.roles.keys.each { |role| it_behaves_like 'view comment', role }
  # end

  context 'view comment' do
    scenario 'correct case for user' do
      login_as create(:user, :user)
      post = create :post, :with_user
      comment = create :comment, :with_user
      visit "/posts/#{post.id}/comments/#{comment.id}"
      puts(page.body)
      #save_and_open_page
      expect(page.find('header').text).to eq "Comment ##{comment.id} on post ##{post.id}"
      expect(page.body).to match comment.content
    end

    scenario 'correct case for admin' do
      login_as create(:user, :admin)
      comment = create :comment, :with_user
      visit "/posts/#{post.id}/comments/#{comment.id}"
      expect(page.find('header').text).to eq "Comment ##{comment.id} on post ##{post.id}"
      expect(page.body).to match comment.content
    end

    scenario 'correct case for moderator' do
      login_as create(:user, :moderator)
      comment = create :comment, :with_user
      visit "/posts/#{post.id}/comments/#{comment.id}"
      expect(page.find('header').text).to eq "Comment ##{comment.id} on post ##{post.id}"
      expect(page.body).to match comment.content
    end
  end

  shared_examples 'edit comment' do
  	scenario "correct case with role '#{role}'"
      login_as users[role.to_sym]
      comment = create :comment, :with_user
      visit "posts/#{post.id}/comments/#{comment.id}"
      expect(page).to have_link 'edit'
      click_on 'edit'
      expect(page.body).to match "Edit comment ##{comment.id}"
      expect(page).to have_selector 'input[value="update"]'
      page.fill_in 'comment[content]', with: 'New content'
      find('input[value="update"]').click
      expect(page.body).to match "Comment ##{comment.id}"
      expect(page.body).to match 'Updated comment'
    end
  end

  context 'edit comment' do
  	User.roles.keys.each { |role| it_behaves_like 'edit comment', role }
  end


  context 'edit comment' do
    scenario 'correct case for admin' do
      login_as create(:user, :admin)
      comment = create :comment, :with_user
      #404
      visit "posts/#{post.id}/comments/#{comment.id}"
      expect(page).to have_link 'edit'
      click_on 'edit'
      expect(page.body).to match "Edit comment ##{comment.id}"
      expect(page).to have_selector 'input[value="update"]'
      page.fill_in 'comment[content]', with: 'New content'
      find('input[value="update"]').click
      expect(page.body).to match "Comment ##{comment.id}"
      expect(page.body).to match 'Updated comment'
    end

    scenario 'correct case for moderator' do
      login_as create(:user, :moderator)
      comment = create :comment, :with_user
      #404
      visit "posts/#{post.id}/comments/#{comment.id}"
      expect(page).to have_link 'edit'
      click_on 'edit'
      expect(page.body).to match "Edit comment ##{comment.id}"
      expect(page).to have_selector 'input[value="update"]'
      page.fill_in 'comment[content]', with: 'New content'
      find('input[value="update"]').click
      expect(page.body).to match "Comment ##{comment.id}"
      expect(page.body).to match 'Updated comment'
    end

    scenario 'correct case for user' do
      login_as create(:user, :user)
      comment = create :comment, :with_user
      #404
      visit "posts/#{post.id}/comments/#{comment.id}"
      puts("posts/#{post.id}/comments/#{comment.id}")
      expect(page).to have_link 'edit'
      click_on 'edit'
      expect(page.body).to match "Edit comment ##{comment.id}"
      expect(page).to have_selector 'input[value="update"]'
      page.fill_in 'comment[content]', with: 'New content'
      find('input[value="update"]').click
      expect(page.body).to match "Comment ##{comment.id}"
      expect(page.body).to match 'Updated comment'
    end
  end
end

