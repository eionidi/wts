require 'rails_helper'

feature 'posts', js: true do
  let(:user) { create :user, :admin }

  before(:each) { login_as user }

  scenario 'list of posts' do
    visit '/posts'
    expect(page.find('header').text).to eq 'Posts'
  end

  context 'create post' do
    scenario 'correct case for admin' do
      login_as create(:user, :admin)
      visit '/posts'
      expect(page).to have_link 'Write post'
      click_on 'Write post'
      sleep 1
      expect(page.find('header').text).to eq 'New post'
      expect(page).to have_field 'post[title]'
      expect(page).to have_field 'post[content]'
      expect(page).to have_selector 'input[value="create"]'
      expect(page).to have_selector 'select[name="post[author_id]"]'
      page.fill_in 'post[title]', with: 'New Post Name'
      page.fill_in 'post[content]', with: 'My first post'
      select 'admin', from: "post[author_id]"
      find('input[value="create"]').click
      expect(page.find('header').text).to match 'Post #'
      expect(page.body).to match '<tr><td>Title:</td><td>New Post Name</td></tr>'
      expect(page.body).to match '<tr><td>Content:</td><td>My first post</td></tr>'
    end

    scenario 'correct case user' do
      visit '/posts'
      expect(page).to have_link 'Write post'
      click_on 'Write post'
      sleep 1
      expect(page.find('header').text).to eq 'New post'
      expect(page).to have_field 'post[title]'
      expect(page).to have_field 'post[content]'
      expect(page).to have_selector 'input[value="create"]'
      expect(page).to have_selector 'select[name="post[author_id]"]'
      page.fill_in 'post[title]', with: 'New Post Name'
      page.fill_in 'post[content]', with: 'My first post'
      select 'admin', from: "post[author_id]"
      find('input[value="create"]').click
      expect(page.find('header').text).to match 'Post #'
      expect(page.body).to match '<tr><td>Title:</td><td>New Post Name</td></tr>'
      expect(page.body).to match '<tr><td>Content:</td><td>My first post</td></tr>'
    end

    scenario 'correct case for moderator' do
      login_as create(:user, :moderator)
      visit '/posts'
      expect(page).to have_link 'Write post'
      click_on 'Write post'
      sleep 1
      expect(page.find('header').text).to eq 'New post'
      expect(page).to have_field 'post[title]'
      expect(page).to have_field 'post[content]'
      expect(page).to have_selector 'input[value="create"]'
      expect(page).to have_selector 'select[name="post[author_id]"]'
      page.fill_in 'post[title]', with: 'New Post Name'
      page.fill_in 'post[content]', with: 'My first post'
      select 'admin', from: "post[author_id]"
      find('input[value="create"]').click
      expect(page.find('header').text).to match 'Post #'
      expect(page.body).to match '<tr><td>Title:</td><td>New Post Name</td></tr>'
      expect(page.body).to match '<tr><td>Content:</td><td>My first post</td></tr>'
    end

    scenario 'incorrect case' do
      login_as create(:user, :admin)
      visit '/posts'
      expect(page).to have_link 'Write post'
      click_on 'Write post'
      expect(page).to have_field 'post[title]'
      expect(page).to have_field 'post[content]'
      expect(page).to have_selector 'select[name="post[author_id]"]'
      expect(page).to have_selector 'input[value="create"]'
      find('select[name="post[author_id]"]').click
      page.fill_in 'post[title]', with: 'a'
      page.fill_in 'post[content]', with: 'My first post'
      find('input[value="create"]').click
      expect(page.find('header').text).to match 'New post'
      expect(page.find('.flash-error').text).not_to be_empty
    end
  end

  context 'delete post' do
    scenario 'correct case for admin' do
      login_as create(:user, :admin)
      post = create :post, :with_user
      visit '/posts'
      expect(page).to have_link post.title
      click_on post.title
      sleep 1
      expect(page.find('header').text).to eq "Post ##{post.id}"
      expect(page).to have_link 'delete'
      click_on 'delete'
      expect(page.find('header').text).to eq 'Posts'
      expect(page.body).not_to match post.title
      expect(page.body).not_to match post.content
    end

    scenario 'correct case for moderator' do
      login_as create(:user, :moderator)
      post = create :post, :with_user
      visit '/posts'
      expect(page).to have_link post.title
      click_on post.title
      sleep 1
      expect(page.find('header').text).to eq "Post ##{post.id}"
      #expect(page).not_to have_link 'delete' раскомментить, когда не будет кнопки
    end

    scenario 'correct case for user' do
      post = create :post, :with_user
      visit '/posts'
      expect(page).to have_link post.title
      click_on post.title
      sleep 1
      expect(page.find('header').text).to eq "Post ##{post.id}"
      #expect(page).not_to have_link 'delete' раскомментить, когда не будет кнопки
    end
  end

  context 'view post' do
    scenario 'correct case for user' do
      user = create :user
      post = create :post, author: user
      visit '/posts'
      expect(page).to have_link post.title
      click_on post.title
      expect(page.find('header').text).to eq "Post ##{post.id}"
      expect(page.body).to match post.title
      expect(page.body).to match post.content
    end

    scenario 'correct case for admin' do
      user = create(:user, :admin)
      post = create :post, author: user
      visit '/posts'
      expect(page).to have_link post.title
      click_on post.title
      expect(page.find('header').text).to eq "Post ##{post.id}"
      expect(page.body).to match post.title
      expect(page.body).to match post.content
    end

    scenario 'correct case for moderator' do
      user = create(:user, :moderator)
      post = create :post, author: user
      visit '/posts'
      expect(page).to have_link post.title
      click_on post.title
      expect(page.find('header').text).to eq "Post ##{post.id}"
      expect(page.body).to match post.title
      expect(page.body).to match post.content
    end
  end

  context 'edit post' do
    scenario 'correct case for admin' do
      user = create(:user, :admin)
      post = create :post, author: user
      visit '/posts'
      expect(page).to have_link post.title
      click_on post.title
      expect(page).to have_link 'edit'
      click_on 'edit'
      sleep 1
      expect(page.body).to match "Edit post ##{post.id}"
      expect(page).to have_selector 'input[value="update"]'
      page.fill_in 'post[title]', with: 'Updated post'
      find('input[value="update"]').click
      expect(page.body).to match "Post ##{post.id}"
      expect(page.body).to match 'Updated post'
    end

    scenario 'correct case for moderator' do
      user = create(:user, :moderator)
      post = create :post, author: user
      visit '/posts'
      expect(page).to have_link post.title
      click_on post.title
      expect(page).to have_link 'edit'
      click_on 'edit'
      sleep 1
      expect(page.body).to match "Edit post ##{post.id}"
      expect(page).to have_selector 'input[value="update"]'
      page.fill_in 'post[title]', with: 'Updated post'
      find('input[value="update"]').click
      expect(page.body).to match "Post ##{post.id}"
      expect(page.body).to match 'Updated post'
    end

    scenario 'correct case for user' do
      user = create(:user, :user)
      post = create :post, author: user
      visit '/posts'
      expect(page).to have_link post.title
      click_on post.title
      expect(page).to have_link 'edit'
      click_on 'edit'
      sleep 1
      expect(page.body).to match "Edit post ##{post.id}"
      expect(page).to have_selector 'input[value="update"]'
      page.fill_in 'post[title]', with: 'Updated post'
      find('input[value="update"]').click
      expect(page.body).to match "Post ##{post.id}"
      expect(page.body).to match 'Updated post'
    end

    scenario 'incorrect case for admin' do
      user = create(:user, :admin)
      post = create :post, author: user
      visit '/posts'
      expect(page).to have_link post.title
      click_on post.title
      expect(page).to have_link 'edit'
      click_on 'edit'
      sleep 1
      expect(page.body).to match "Edit post ##{post.id}"
      expect(page).to have_selector 'input[value="update"]'
      page.fill_in 'post[title]', with: 'a'
      find('input[value="update"]').click
      expect(page.find('header').text).to eq "Edit post ##{post.id}"
      expect(page.body).to match 'a'
      expect(page.find('.flash-error').text).not_to be_empty
    end

    scenario 'incorrect case for moderator' do
      user = create(:user, :moderator)
      post = create :post, author: user
      visit '/posts'
      expect(page).to have_link post.title
      click_on post.title
      expect(page).to have_link 'edit'
      click_on 'edit'
      sleep 1
      expect(page.body).to match "Edit post ##{post.id}"
      expect(page).to have_selector 'input[value="update"]'
      page.fill_in 'post[title]', with: 'a'
      find('input[value="update"]').click
      expect(page.find('header').text).to eq "Edit post ##{post.id}"
      expect(page.body).to match 'a'
      expect(page.find('.flash-error').text).not_to be_empty
    end

    scenario 'incorrect case for user' do
      user = create :user
      post = create :post, author: user
      visit '/posts'
      expect(page).to have_link post.title
      click_on post.title
      expect(page).to have_link 'edit'
      click_on 'edit'
      sleep 1
      expect(page.body).to match "Edit post ##{post.id}"
      expect(page).to have_selector 'input[value="update"]'
      page.fill_in 'post[title]', with: 'a'
      find('input[value="update"]').click
      expect(page.find('header').text).to eq "Edit post ##{post.id}"
      expect(page.body).to match 'a'
      expect(page.find('.flash-error').text).not_to be_empty
    end
  end
end
