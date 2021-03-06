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
      login_as users[:admin]
      comment = create :comment, author: users[:user]
      stub_request(:get, "https://staging-booth-my.artec3d.com/users/exist.json?user%5Bemail%5D=#{comment.last_actor.email}").
      to_return(status: 200, body: { 'exist' => false }.to_json)
      visit "/posts/#{comment.post.id}/comments/#{comment.id}"
      expect(page.find('header').text).to eq "Comment ##{comment.id} on post ##{comment.post.id}"
      expect(page).to have_link 'delete'
      click_on 'delete'
      expect(page.find('header').text).to eq "Post ##{comment.post.id}"
      expect(page.body).not_to match comment.content
    end

    scenario 'correct case for moderator' do
      login_as users[:moderator]
      comment = create :comment, author: users[:moderator]
      stub_request(:get, "https://staging-booth-my.artec3d.com/users/exist.json?user%5Bemail%5D=#{comment.last_actor.email}").
      to_return(status: 200, body: { 'exist' => false }.to_json)
      visit "/posts/#{comment.post.id}/comments/#{comment.id}"
      expect(page.find('header').text).to eq "Comment ##{comment.id} on post ##{comment.post.id}"
      expect(page).not_to have_link 'delete'
    end

    scenario 'correct case for user' do
      login_as users[:user]
      comment = create :comment, author: users[:user]
      stub_request(:get, "https://staging-booth-my.artec3d.com/users/exist.json?user%5Bemail%5D=#{comment.last_actor.email}").
      to_return(status: 200, body: { 'exist' => false }.to_json)
      visit "/posts/#{comment.post.id}/comments/#{comment.id}"
      expect(page.find('header').text).to eq "Comment ##{comment.id} on post ##{comment.post.id}"
      expect(page).not_to have_link 'delete'
    end
  end

  shared_examples 'view comment' do |role|
    scenario "correct case with role '#{role}'" do
  	  login_as users[role.to_sym]
      comment = create :comment, author: users[role.to_sym]
      stub_request(:get, "https://staging-booth-my.artec3d.com/users/exist.json?user%5Bemail%5D=#{comment.last_actor.email}").
      to_return(status: 200, body: { 'exist' => false }.to_json)
      visit "/posts/#{comment.post.id}/comments/#{comment.id}"
      expect(page.find('header').text).to eq "Comment ##{comment.id} on post ##{comment.post.id}"
      expect(page.body).to match comment.content
    end
  end

  shared_examples 'view someones comment' do |role|
    scenario "correct case with role '#{role}'" do
      login_as users[role.to_sym]
      # other_user = (users.values - [users[role.to_sym]]).sample
      comment = create :comment, :with_user
      stub_request(:get, "https://staging-booth-my.artec3d.com/users/exist.json?user%5Bemail%5D=#{comment.last_actor.email}").
      to_return(status: 200, body: { 'exist' => false }.to_json)
      visit "/posts/#{comment.post.id}/comments/#{comment.id}"
      expect(page.find('header').text).to eq "Comment ##{comment.id} on post ##{comment.post.id}"
      expect(page.body).to match comment.content
    end
  end

  context 'view comment' do
    User.roles.keys.each { |role| it_behaves_like 'view comment', role }
    User.roles.keys.each { |role| it_behaves_like 'view someones comment', role }
  end

  

  shared_examples 'edit comment' do |role|
  	scenario "correct case with role '#{role}'" do
      login_as users[role.to_sym]
      comment = create :comment, author: users[role.to_sym]
      stub_request(:get, "https://staging-booth-my.artec3d.com/users/exist.json?user%5Bemail%5D=#{comment.last_actor.email}").
      to_return(status: 200, body: { 'exist' => false }.to_json)
      visit "posts/#{comment.post.id}/comments/#{comment.id}"
      expect(page).to have_link 'edit'
      click_on 'edit'
      expect(page.body).to match "Edit comment ##{comment.id}"
      expect(page).to have_selector 'input[value="update"]'
      page.fill_in 'comment[content]', with: 'New content'
      find('input[value="update"]').click
      expect(page.body).to match "Post ##{comment.post.id}"
      expect(page.body).to match 'New content'
    end
  end

  context 'edit comment' do
  	User.roles.keys.each { |role| it_behaves_like 'edit comment', role }
  end

  context 'edit  someones comment' do
    scenario 'correct case for admin' do
      login_as users[:admin]
      comment = create :comment, author: users[:user]
      stub_request(:get, "https://staging-booth-my.artec3d.com/users/exist.json?user%5Bemail%5D=#{comment.last_actor.email}").
      to_return(status: 200, body: { 'exist' => false }.to_json)
      visit "posts/#{comment.post.id}/comments/#{comment.id}"
      expect(page).to have_link 'edit'
      click_on 'edit'
      expect(page.body).to match "Edit comment ##{comment.id}"
      expect(page).to have_selector 'input[value="update"]'
      page.fill_in 'comment[content]', with: 'New content'
      find('input[value="update"]').click
      expect(page.find('header').text).to eq "Post ##{comment.post.id}"
      expect(page.body).to match 'New content'
    end

    scenario 'correct case for moderator' do
      login_as users[:moderator]
      comment = create :comment, author: users[:admin]
      stub_request(:get, "https://staging-booth-my.artec3d.com/users/exist.json?user%5Bemail%5D=#{comment.last_actor.email}").
      to_return(status: 200, body: { 'exist' => false }.to_json)
      visit "posts/#{comment.post.id}/comments/#{comment.id}"
      expect(page).to have_link 'edit'
      click_on 'edit'
      expect(page.body).to match "Edit comment ##{comment.id}"
      expect(page).to have_selector 'input[value="update"]'
      page.fill_in 'comment[content]', with: 'New content'
      find('input[value="update"]').click
      expect(page.body).to match "Post ##{comment.post.id}"
      expect(page.body).to match 'New content'
    end

    scenario 'correct case for user' do
      WebMock.allow_net_connect!
      login_as users[:user]
      comment = create :comment, author: users[:moderator]
      # stub_request(:get, "https://staging-booth-my.artec3d.com/users/exist.json?user%5Bemail%5D=#{comment.last_actor.email}").
      # to_return(status: 200, body: { 'exist' => false }.to_json)
      visit "posts/#{comment.post.id}/comments/#{comment.id}"
      expect(page).not_to have_link 'edit'
      WebMock.disable_net_connect!
    end
  end

  context 'edit any comments at his post' do
  	scenario 'correct case for user' do
  	  login_as users[:user]
  	  post = create :post, author: users[:user]
      comment = create :comment, author: users[:admin], post: post
      stub_request(:get, "https://staging-booth-my.artec3d.com/users/exist.json?user%5Bemail%5D=#{comment.last_actor.email}").
      to_return(status: 200, body: { 'exist' => false }.to_json)
      visit "posts/#{comment.post.id}/comments/#{comment.id}"
      expect(page).to have_link 'edit'
      click_on 'edit'
      expect(page.body).to match "Edit comment ##{comment.id}"
      expect(page).to have_selector 'input[value="update"]'
      page.fill_in 'comment[content]', with: 'New content'
      find('input[value="update"]').click
      expect(page.body).to match "Post ##{comment.post.id}"
      expect(page.body).to match 'New content'
    end
  end

  context 'redirect on My Artec' do
    scenario 'correct case for admin' do
      login_as users[:user]
      comment = create :comment, author: users[:admin]
      stub_request(:get, "https://staging-booth-my.artec3d.com/users/exist.json?user%5Bemail%5D=#{comment.last_actor.email}").
        to_return(status: 200, body: { 'exist' => true }.to_json)
      visit "posts/#{comment.post.id}/comments/#{comment.id}"
      expect(page).to have_link 'On MyArtec3D'
      click_on 'On MyArtec3D'
      expect(current_url).to match 'https://staging-booth-my.artec3d.com'
    end
  end
end

