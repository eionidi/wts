require 'rails_helper'
RSpec::Matchers.define_negated_matcher :not_change, :change

describe PostsController do
  let(:posts) do
    {
      post: create(:post, :title, :content, :author),
    }
  end
  let(:post_attrs) do
    {
      title: Faker::Lorem.sentence,
      content: Faker::Lorem.paragraph,
      author: author { create :user }
    }
  end
  let(:post_params) do
    {
      title: Faker::Lorem.sentence,
      content: Faker::Lorem.paragraph,
      author: author { create :user }
    }
  end

  def post_updated(post)
    post.reload
    expect(post.title).to eq post_params[:title]
    expect(post.content).to eq post_params[:content]
    expect(response).to redirect_to "/posts/#{post.id}"
    expect(flash[:notice]).to eq "Post ##{post.id} updated!"
  end

  def post_not_updated(post)
    post.reload
    expect(post.title).to eq user_attrs[:title]
    expect(post.content).to eq user_attrs[:content]
  end

  #before(:each) { sign_up(users[:admin]) }

  describe '#index' do
    it 'test post index' do
      #sign_in users[:user]
      post = create :post, author: user
      posts.values.each(&:reload)
      get :index
      expect(response).to redirect_to '/posts'
      expect(response).to have_http_status(200).and render_template 'index'
      expect(response.body).to match 'Posts'
      expect(controller.instance_variable_get('@posts')).to eq Post.all
    end
    it 'should show list of posts to admin' do
      posts.values.each(&:reload)
      get :index
      expect(response).to have_http_status(200).and render_template 'index'
      expect(response.body).to match 'Posts'
      expect(controller.instance_variable_get('@posts')).to eq Post.all
    end
    it 'should show list of posts to moderator' do
      #sign_in users[:moderator]
      post = create :post, author: moderator
      posts.values.each(&:reload)
      get :index
      expect(response).to have_http_status(200).and render_template 'index'
      expect(response.body).to match 'Posts'
      expect(controller.instance_variable_get('@posts')).to eq Post.all
    end
    it 'should return JSON response' do
      posts.values.each(&:reload)
      get :index, format: :json
      expect(response).to have_http_status 200
      expect(response.body).to eq Post.all.to_json only: %i(title author updated_at)
    end
  end

  shared_examples 'show post' do |role|
    it "with role '#{role}'" do
      post = posts[role.to_sym]
      get :show, id: post.id
      expect(response).to have_http_status(200).and render_template 'show'
      expect(response.body).to match post.title
      expect(controller.instance_variable_get('@post')).to eq post
    end
  end

  describe '#show' do
    #Post.roles.keys.each { |role| it_behaves_like 'show post', role }
    it 'should show post to user' do
      sign_in users[:user]
      get :show, id: Post.last.id
    end

    it 'should show post to moderator' do
      sign_in users[:moderator]
      get :show, id: Post.last.id
    end

    it 'should show user to admin' do
      get :show, id: Post.last.id
    end

    it 'should return 404 w/wrong post id' do
      get :show, id: Post.last.id + 1
      expect(response).to have_http_status(404)
    end
  end

  describe '#destroy' do
    it 'should destroy post' do
      post = create :post, author: admin
      expect { delete :destroy, id: post.id }.to change { Post.count }.by -1
      expect(response).to redirect_to '/posts'
    end

    it 'should not destroy post' do
      expect { delete :destroy, id: Post.last.id + 1 }.to change { Post.count }.by 0
      expect(response).to have_http_status(404)
    end
  end

  shared_examples 'update post' do |attr_name|
    it "with empty '#{attr_name}'" do
      post = create :post, author: admin
      patch :update, id: post.id, post: post_params.merge(attr_name => '')
      post_not_updated post
      expect(response).to render_template 'edit'
      expect(flash[:error]).not_to be_empty
    end
  end

  describe '#update' do
    it 'should update all fields' do
      post = create :post, post_attrs
      patch :update, id: post.id, post: post_params
      post_updated post
    end
    it 'should save updated_at' do
      post = create :post, post_attrs
      time = Faker::Time.between 1.year.ago, 1.year.from_now
      Timecop.freeze time
      expect { patch :update, id: post.id, post: post_params }.to change { post.reload.updated_at.to_i }.to time.to_i
      Timecop.return
    end
    it 'should ignore not permitted attrs' do
      post = create :post, post_attrs
      old_id = post.id.freeze
      patch :update, id: post.id, post: post_params.merge(id: Post.last.id + 1)
      post_updated post
      expect(post.id).to eq old_id
    end
    it 'should not update w/wrong post id' do
      post = create :post, post_attrs
      patch :update, id: (Post.last.id + 1), post: post_params
      post_not_updated post
      expect(response).to have_http_status(404)
    end
    %i(title content author).each { |attr_name| it_behaves_like 'update post', attr_name }
  end
end
