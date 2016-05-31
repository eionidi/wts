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
  
  describe '#new' do
    it 'should show new user form' do
      get :new
      expect(response).to have_http_status(200).and render_template 'new'
      expect(response.body).to match 'New user'
    end
  end

  describe '#create' do
    it 'should create user with all fields filled' do      
      expect { post :create, user: user_params }.to change { User.count }.by 1
      user = User.last
      expect(user.email).to eq user_params[:email]
      expect(user.name).to eq user_params[:name]
      expect(response).to redirect_to "/users/#{user.id}"
      expect(flash[:notice]).to eq "User ##{user.id} created!"
    end
     
    it 'should not create user w/o name' do 
      expect { post :create, user: user_params.merge(name: nil) }.to not_change { User.count }
      expect(response.body).to match 'New user'
      expect(flash[:error]).not_to be_empty
    end
    
    it 'should not create user w/o email' do 
      expect{post :create, user: { email: Faker::Internet.email } }.to change { User.count }.by 0
      expect(response.body).to match 'New user'
      expect(flash[:error]).not_to be_empty      
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
    %i(name email).each { |attr_name| it_behaves_like 'update user', attr_name }
  end
end