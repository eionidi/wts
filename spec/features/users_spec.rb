require 'rails_helper'

feature 'users', js: true do
  let(:user) { create :user, :admin }

  before(:each) { login_as user }

  scenario 'list of users' do
    visit '/users'
    expect(page).to have_selector 'header'
    expect(page.find('header').text).to eq 'List of Users'
  end

  scenario 'list of users' do
    login_as create(:user, :user)
    visit '/users'
    expect(page.current_path).to eq '/'
  end

  scenario 'list of users' do
    login_as create(:user, :admin)
    visit '/users'
    expect(page.current_path).to eq '/users'
  end

  scenario 'list of users' do
    login_as create(:user, :moderator)
    visit '/users'
    expect(page.current_path).to eq '/users'
  end

  context 'delete user' do
    scenario 'correct case' do
      user = create :user
      visit '/users'
      expect(page).to have_link user.id
      click_on user.id
      sleep 1
      expect(page.find('header').text).to eq "User ##{user.id}"
      expect(page).to have_link 'delete'
      click_on 'delete'
      expect(page.find('header').text).to eq 'List of Users'
      expect(page.body).not_to match "<tr><td>E-Mail:</td><td>#{user.email}</td></tr>"
      expect(page.body).not_to match "<tr><td>Name:</td><td>#{user.name}</td></tr>"
    end
  end

  #сценарий просмотра пользователя
  context 'view user' do
    scenario 'correct case for user' do
      user = create(:user, :user)
      visit '/users'
      expect(page).to have_link user.id
      click_on user.id
      sleep 1
      expect(page.find('header').text).to eq "User ##{user.id}"
      expect(page.body).to match user.email
      expect(page.body).to match user.name
    end

    scenario 'correct case for moderator' do
      user = create(:user, :moderator)
      visit '/users'
      expect(page).to have_link user.id
      click_on user.id
      sleep 1
      expect(page.find('header').text).to eq "User ##{user.id}"
      expect(page.body).to match user.email
      expect(page.body).to match user.name
    end

    scenario 'correct case for admin' do
      user = create(:user, :admin)
      visit '/users'
      expect(page).to have_link user.id
      click_on user.id
      sleep 1
      expect(page.find('header').text).to eq "User ##{user.id}"
      expect(page.body).to match user.email
      expect(page.body).to match user.name
    end
  end

  #сценарий редактирования пользователя
  context 'edit user' do
    scenario 'correct case' do
      user = create :user
      visit '/users'
      expect(page).to have_link user.id
      click_on user.id
      expect(page).to have_link 'edit'
      click_on 'edit'
      sleep 1
      expect(page.body).to match "Edit User ##{user.id}"
      expect(page).to have_selector 'input[value="update"]'
      page.fill_in 'user[email]', with: 'newemail@name.new'
      find('input[value="update"]').click
      expect(page.body).to match "User ##{user.id}"
      expect(page.body).to match 'newemail@name.new'
      expect(page.body).to match user.name
    end

    scenario 'incorrect case' do
      login_as create(:user, :user)
      visit '/users'
      expect(page).to have_link user.id
      click_on user.id
      expect(page).to have_link 'edit'
      click_on 'edit'
      sleep 1
      expect(page.find('header').text).to eq "Edit User ##{user.id}"
      expect(page).to have_selector 'input[value="update"]'
      page.fill_in 'user[email]', with: 'wrong_email'
      find('input[value="update"]').click
      expect(page.find('header').text).to eq "Edit User ##{user.id}"
      expect(page.body).to match 'wrong_email'
      expect(page.body).to match user.name
      expect(page.find('.flash-error').text).not_to be_empty
    end
  end
end
