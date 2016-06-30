require 'rails_helper'

feature 'comments', js: true do
  let(:user) { create :user, :admin }
  let(:post) { create :post, :with_user }

  def edit_comment(comment)
    post = create :post, :with_user
   #  visit '/posts'
   #  expect(page).to have_link post.title
   #  click_on post.title
   #  expect(page.find('header').text).to eq "Post ##{post.id}"
   #  expect(page).to have_link 'add comment'
   #  click_on 'add comment'
    comment = create :comment
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

  def not_edit_comment(comment)
  	post = create :post, :with_user
    comment = create :comment
    visit "posts/#{post.id}/comments/#{comment.id}"
    expect(page).to have_link 'edit'
    click_on 'edit'
    expect(page.body).to match "Edit comment ##{comment.id}"
    expect(page).to have_selector 'input[value="update"]'
    page.fill_in 'comment[content]', with: 'a'
    find('input[value="update"]').click
    expect(page.find('header').text).to eq "Edit comment ##{comment.id}"
    expect(page.body).to match 'a'
    expect(page.find('.flash-error').text).not_to be_empty
  end

  # def create_comment(post)
  # 	#post = create :post, :with_user, with_post
  # 	#post = Post.new(title: Faker::Lorem.sentence, content: Faker::Lorem.paragraph, author: user)
  #   # visit '/posts'
  #   # expect(page).to have_link post.title
  #   # click_on post.title
  #   # expect(page.find('header').text).to eq "Post ##{post.id}"
  #   visit "/posts/#{post.id}"
  #   expect(page).to have_link 'add comment'
  #   click_on 'add comment'
  #   expect(page.find('header').text).to eq 'New comment'
  #   expect(page).to have_field 'comment[content]'
  #   expect(page).to have_selector 'input[value="create"]'
  #   page.fill_in 'post[content]', with: 'My first comment'
  #   find('input[value="create"]').click
  #   expect(page.find('header').text).to match 'Comment #'
  #   expect(page.body).to match '<tr><td>Content:</td><td>My first comment</td></tr>'
  # end

  def view_comment(comment)
    visit '/posts'
    expect(page).to have_link post.title
    click_on post.title
    expect(page.find('header').text).to eq "Post ##{post.id}"
    expect(page.body).to match comment.content
  end

  before(:each) { login_as user }

  context 'create comment' do
    scenario 'correct case for admin' do
      login_as create(:user, :admin)
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

    scenario 'correct case for user' do
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

    scenario 'correct case for moderator' do
      login_as create(:user, :moderator)
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
end

