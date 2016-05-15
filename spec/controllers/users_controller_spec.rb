require 'rails_helper'

describe UsersController do
  let(:users) do
    {
      user: create(:user, :user),
      moderator: create(:user, :moderator),
      admin: create(:user, :admin)
    }
  end

  describe '#index' do
    it 'should show list of users' do
      get :index
      expect(response).to render_template 'index'
      expect(response.body).to match 'List of Users'
    end
  end

  shared_examples 'show user' do |role|
    it "with role '#{role}'" do
      user = users[role.to_sym]
      get :show, id: user.id
      expect(response).to render_template 'show'
      expect(response.body).to match user.email
    end
  end

  describe '#show' do
    User.roles.keys.each { |role| it_behaves_like 'show user', role }
  end
end
