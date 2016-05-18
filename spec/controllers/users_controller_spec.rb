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
      users.values.each(&:reload)
      get :index
      expect(response).to have_http_status(200).and render_template 'index'
      expect(response.body).to match 'List of Users'
      expect(controller.instance_variable_get('@users')).to eq User.all
    end
    it 'should return JSON response' do
      users.values.each(&:reload)
      get :index, format: :json
      expect(response).to have_http_status 200
      expect(response.body).to eq User.all.to_json only: %i(id email role name created_at)
    end
  end

  shared_examples 'show user' do |role|
    it "with role '#{role}'" do
      user = users[role.to_sym]
      get :show, id: user.id
      expect(response).to have_http_status(200).and render_template 'show'
      expect(response.body).to match user.email
      expect(controller.instance_variable_get('@user')).to eq user
    end
  end

  describe '#show' do
    User.roles.keys.each { |role| it_behaves_like 'show user', role }

    it 'should return 404 w/wrong user id' do
      get :show, id: User.last.id + 1
      expect(response).to have_http_status(404)
    end
  end
end
