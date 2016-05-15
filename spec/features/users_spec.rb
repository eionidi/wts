require 'rails_helper'

feature 'users', js: true do
  scenario 'list of users' do
    visit '/users'
    expect(page).to have_selector 'header'
    expect(page.find('header').text).to eq 'List of Users'
  end
end
