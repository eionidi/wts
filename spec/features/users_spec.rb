require 'rails_helper'

feature 'users', js: true do
  scenario 'list of users' do
    visit '/users'
    expect(page).to have_selector 'header'
    expect(page.find('header').text).to eq 'List of Users'
  end

  context 'create user' do
    scenario 'correct case' do
      visit '/users'
      expect(page).to have_link 'new User'
      click_on 'new User'
      expect(page.find('header').text).to eq 'New user'
      expect(page).to have_field 'user[name]'
      expect(page).to have_field 'user[email]'
      expect(page).to have_selector 'input[value="create"]'
      page.fill_in 'user[name]', with: 'New User Name'
      page.fill_in 'user[email]', with: 'newuser@name.new'
      find('input[value="create"]').click
      expect(page.find('header').text).to match 'User #'
      expect(page.body).to match '<tr><td>E-Mail:</td><td>newuser@name.new</td></tr>'
      expect(page.body).to match '<tr><td>Name:</td><td>New User Name</td></tr>'
    end

    scenario 'incorrect case' do
      visit '/users'
      expect(page).to have_link 'new User'
      click_on 'new User'
      expect(page).to have_field 'user[name]'
      expect(page).to have_field 'user[email]'
      expect(page).to have_selector 'input[value="create"]'
      page.fill_in 'user[name]', with: 'a'
      page.fill_in 'user[email]', with: 'newuser@name.new'
      find('input[value="create"]').click
      expect(page.find('header').text).to match 'New user'
      expect(page.find('.flash-error').text).not_to be_empty
    end
  end

  context 'delete user' do
    scenario 'correct case' do
      user = create :user
      visit '/users'
      expect(page).to have_link user.id
      click_on user.id
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
    scenario 'correct case' do
      user = create :user
      visit '/users'
      expect(page).to have_link user.id
      click_on user.id
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
      puts page.body.inspect
      expect(page.body).to match "Edit User ##{user.id}"
      expect(page).to have_selector 'input[value="update"]'
      page.fill_in 'user[email]', with: 'newemail@name.new'
      find('input[value="update"]').click
      expect(page.body).to match "User ##{user.id}"
      expect(page.body).to match 'newemail@name.new'
      expect(page.body).to match user.name
    end
  
    scenario 'incorrect case' do
      user = create :user
      visit '/users'
      expect(page).to have_link user.id
      click_on user.id
      expect(page).to have_link 'edit'
      click_on 'edit'
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
