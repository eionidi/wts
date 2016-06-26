require 'rails_helper'
RSpec::Matchers.define_negated_matcher :not_change, :change

describe UsersController do
  let(:users) do
    {
      user: create(:user, :user),
      moderator: create(:user, :moderator),
      admin: create(:user, :admin)
    }
  end
  let(:user_attrs) do
    {
      email: Faker::Internet.email,
      name: Faker::Name.name,
      role: User.roles.values.sample
    }
  end
  let(:user_params) do
    {
      email: Faker::Internet.email,
      name: Faker::Name.name,
      role: (User.roles.values - [user_attrs[:role]]).sample
    }
  end

  def user_updated(user)
    user.reload
    expect(user.email).to eq user_params[:email]
    expect(user.name).to eq user_params[:name]
    expect(User.roles[user.role]).to eq user_params[:role]
    expect(response).to redirect_to "/users/#{user.id}"
    expect(flash[:notice]).to eq "User ##{user.id} updated!"
  end

  def user_not_updated(user)
    user.reload
    expect(user.email).to eq user_attrs[:email]
    expect(user.name).to eq user_attrs[:name]
    expect(User.roles[user.role]).to eq user_attrs[:role]
  end

  before(:each) { sign_in(users[:admin]) }

  describe '#index' do
    it 'should show list of users to admin' do
      users.values.each(&:reload)
      get :index
      expect(response).to have_http_status(200).and render_template 'index'
      expect(response.body).to match 'List of Users'
      expect(controller.instance_variable_get('@users')).to eq User.all
    end

    it 'should show list of users to moderator' do
      sign_in users[:moderator]
      users.values.each(&:reload)
      get :index
      expect(response).to have_http_status(200).and render_template 'index'
      expect(response.body).to match 'List of Users'
      expect(controller.instance_variable_get('@users')).to eq User.all
    end

    it 'should not show list of users to user' do
      sign_in users[:user]
      users.values.each(&:reload)
      get :index
      expect(response).to redirect_to '/'
      expect(controller.instance_variable_get('@users')).not_to eq User.all
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
    it 'should not show user to user' do
      sign_in users[:user]
      get :show, id: User.last.id
      expect(response).to redirect_to '/'
    end

    it 'should show user to moderator' do
      sign_in users[:moderator]
      get :show, id: User.last.id
      expect(response).to have_http_status(200).and render_template 'show'
    end

    it 'should show user to admin' do
      get :show, id: User.last.id
      expect(response).to have_http_status(200).and render_template 'show'
    end

    it 'should return 404 w/wrong user id' do
      get :show, id: User.last.id + 1
      expect(response).to have_http_status(404)
    end
  end

  describe '#destroy' do
    it 'should destroy user' do
      user = create :user, user_attrs
      expect { delete :destroy, id: user.id }.to change { User.count }.by -1
      expect(response).to redirect_to '/users'
    end

    it 'should not destroy user' do
      expect { delete :destroy, id: User.last.id + 1 }.to change { User.count }.by 0
      expect(response).to have_http_status(404)
    end
  end

  shared_examples 'update user' do |attr_name|
    it "with empty '#{attr_name}'" do
      user = create :user, user_attrs
      patch :update, id: user.id, user: user_params.merge(attr_name => '')
      user_not_updated user
      expect(response).to render_template 'edit'
      expect(flash[:error]).not_to be_empty
    end
  end

  describe '#update' do
    it 'should update all fields' do
      user = create :user, user_attrs
      patch :update, id: user.id, user: user_params
      user_updated user
    end
    it 'should save updated_at' do
      user = create :user, user_attrs
      time = Faker::Time.between 1.year.ago, 1.year.from_now
      Timecop.freeze time
      expect { patch :update, id: user.id, user: user_params }.to change { user.reload.updated_at.to_i }.to time.to_i
      Timecop.return
    end
    it 'should ignore not permitted attrs' do
      user = create :user, user_attrs
      old_id = user.id.freeze
      patch :update, id: user.id, user: user_params.merge(id: User.last.id + 1)
      user_updated user
      expect(user.id).to eq old_id
    end
    it 'should not update w/wrong user id' do
      user = create :user, user_attrs
      patch :update, id: (User.last.id + 1), user: user_params
      user_not_updated user
      expect(response).to have_http_status(404)
    end

    it 'should update role by admin' do
      sign_in users[:admin]
      user = create :user, :user
      # OK, everytime you update user as `patch :update, id: user.id, user: user_params`
      # WHY you try to update him now as `patch :update, role: user_params`???
      patch :update, role: user_params.merge(attr_name => 'moderator')#:role=>"2"
      expect(User.roles[user.role]).to eq user_params[:role]
      expect(response).to redirect_to "/users/#{user.id}"
      expect(flash[:notice]).to eq "User ##{user.id} updated!"
    end

    %i(name email).each { |attr_name| it_behaves_like 'update user', attr_name }
  end
end
