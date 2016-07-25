require 'rails_helper'
RSpec::Matchers.define_negated_matcher :not_change, :change

describe LikesController do
  let(:users) do
    {
      user: create(:user, :user),
      moderator: create(:user, :moderator),
      admin: create(:user, :admin)
    }
  end
  let(:posts) do
    {
      user: create(:post, author: users[:user]),
      moderator: create(:post, author: users[:moderator]),
      admin: create(:post, author: users[:admin])
    }
  end
  let(:likes) do
    {
      user: create(:like, user: users[:user], post: posts[:admin]),
      moderator: create(:like, user: users[:moderator], post: posts[:user]),
      admin: create(:like, user: users[:admin], post: posts[:moderator])
    }
  end

  describe 'index' do
    it "should show likes to admin" do
      sign_in users[:admin]
      like = likes.values.each(&:reload).sample
      get :index, post_id: like.post.id
      expect(response).to have_http_status(200).and render_template 'index'
      expect(response.body).to match 'Likes'
      expect(controller.instance_variable_get('@likes')).to eq like.post.likes
    end

    it "should show likes to moderator" do
      sign_in users[:moderator]
      like = likes.values.each(&:reload).sample
      get :index, id: like.id, post_id: like.post.id
      expect(response).to have_http_status(200).and render_template 'index'
      expect(response.body).to match 'Likes'
      expect(controller.instance_variable_get('@likes')).to eq like.post.likes
    end

    it "should show likes to user" do
      sign_in users[:user]
      like = likes.values.each(&:reload).sample
      get :index, id: like.id, post_id: like.post.id
      expect(response).to redirect_to "/"
      expect(response.body).to match ' '
    end
  end

  shared_examples 'create like on someones post' do |role|
    it "with role '#{role}'" do
      sign_in users[role.to_sym]
      post = create :post, :with_user
      expect { xhr(:post, :create, post_id: post.id) }.to change { post.likes.count }.by 1
      like = post.likes.last
      expect(like.user).to eq users[role.to_sym]
    end
  end

  shared_examples 'should not create like on own post' do |role|
    it "with role '#{role}'" do
      sign_in users[role.to_sym]
      post = create :post, author: users[role.to_sym]
      expect { xhr(:post, :create, post_id: post.id) }.to not_change { Like.count }
    end
  end 

  describe '#create' do
    User.roles.keys.each { |role| it_behaves_like 'create like on someones post', role }
    User.roles.keys.each { |role| it_behaves_like 'should not create like on own post', role }
  end 

  shared_examples 'destroy own like' do |role|
    it "with role '#{role}'" do
      sign_in users[role.to_sym]
      like = create :like, user: users[role.to_sym]
      expect { xhr :delete, :destroy, post_id: like.post.id, id: like.id }.to change { Like.count }.by -1
    end
  end

  shared_examples 'destroy someones like' do |role|
    it "with role '#{role}'" do
      sign_in users[role.to_sym]
      like = create :like, :with_user
      expect { xhr :delete, :destroy, post_id: like.post.id, id: like.id }.to not_change { Like.count }
    end
  end

  describe '#destroy' do
    User.roles.keys.each { |role| it_behaves_like 'destroy own like', role }
    User.roles.keys.each { |role| it_behaves_like 'destroy someones like', role }
  end
end
