require 'rails_helper'
RSpec::Matchers.define_negated_matcher :not_change, :change

describe PostsController do
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
  let(:post_attrs) do
    {
      title: Faker::Lorem.sentence,
      content: Faker::Lorem.paragraph,
      author: create(:user)
    }
  end
  let(:post_params) do
    {
      title: Faker::Lorem.sentence,
      content: Faker::Lorem.paragraph
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
    expect(post.title).to eq post_attrs[:title]
    expect(post.content).to eq post_attrs[:content]
  end

  shared_examples 'index' do |role|
    it "with role '#{role}'" do
      sign_in users[role.to_sym]
      posts.values.each(&:reload)
      get :index
      expect(response).to have_http_status(200).and render_template 'index'
      expect(response.body).to match 'Posts'
      expect(controller.instance_variable_get('@posts')).to eq Post.all.order(updated_at: :desc)
    end
  end

  describe '#index' do
    User.roles.keys.each { |role| it_behaves_like 'index', role }
  end

  shared_examples 'show post' do |role|
    it "with role '#{role}'" do
      sign_in users[role.to_sym]
      post = posts.values.each(&:reload).sample
      get :show, id: post.id
      expect(response).to have_http_status(200).and render_template 'show'
      expect(response.body).to match post.title
      expect(controller.instance_variable_get('@post')).to eq post
    end
  end

  describe '#show' do
    User.roles.keys.each { |role| it_behaves_like 'show post', role }

    it 'should return 404 w/wrong post id' do
      sign_in users.values.sample
      # posts.values.each(&:reload)
      # get :show, id: Post.last.id + 1
      get :show, id: (Post.last.try(:id) || 0) + 1
      expect(response).to have_http_status(404)
    end
  end

  shared_examples 'new post' do |role|
    it "with role '#{role}'" do
      sign_in users[role.to_sym]
      get :new
      expect(response).to have_http_status(200).and render_template 'new'
      expect(response.body).to match 'New post'
    end
  end
  describe '#new' do
    User.roles.keys.each { |role| it_behaves_like 'new post', role }
  end

  shared_examples 'create post' do |role|
    it "with role '#{role}'" do
      sign_in users[role.to_sym]
      expect { post :create, post: post_attrs }.to change { Post.count }.by 1
      post = Post.last
      expect(response).to redirect_to "/posts/#{post.id}"
      expect(flash.now[:notice]).to eq "Post ##{post.id} created!"
      expect(post.author).to eq users[role.to_sym]
    end
  end

  describe '#create' do
    User.roles.keys.each { |role| it_behaves_like 'create post', role }

    it 'should save with image' do
      sign_in users.values.sample
      expect { post :create,
               post: post_attrs.merge(image: fixture_file_upload('fixtures/post_image.png', 'image/png')) }.
        to change { Post.count }.by 1
      expect(Post.last.image).to be_exists
    end
  end

  describe '#destroy' do
    it 'admin should destroy post' do
      sign_in users[:admin]
      post = create :post, post_attrs
      expect { delete :destroy, id: post.id }.to change { Post.count }.by -1
      expect(response).to redirect_to '/posts'
    end

    it 'admin should not destroy post w/wrong id' do
      sign_in users[:admin]
      posts.values.each(&:reload)
      expect { delete :destroy, id: (Post.last.try(:id) || 0) + 1 }.to not_change { Post.count }
      expect(response).to have_http_status(404)
    end

    it 'user should not destroy post' do
      sign_in users[:user]
      post = create :post, post_attrs
      expect { delete :destroy, id: post.id }.to not_change { Post.count }
      expect(response).to redirect_to '/'
    end

    it 'moderator should not destroy post' do
      sign_in users[:moderator]
      post = create :post, post_attrs
      expect { delete :destroy, id: post.id }.to not_change { Post.count }
      expect(response).to redirect_to '/'
    end
  end

  shared_examples 'update post' do |attr_name|
    it "with empty '#{attr_name}'" do
      sign_in users[:admin]
      post = create :post, post_attrs
      patch :update, id: post.id, post: post_params.merge(attr_name => '')
      post_not_updated post
      expect(response).to render_template 'edit'
      expect(flash[:error]).not_to be_empty
    end
  end

  shared_examples'update own post' do |role|
    it "with role '#{role}'" do
      sign_in users[role.to_sym]
      post = create :post, post_attrs
      patch :update, id: posts[role.to_sym].id, post: post_params
      post_updated posts[role.to_sym]
    end
  end

  describe '#update' do
    User.roles.keys.each { |role| it_behaves_like 'update own post', role }

    it 'user should not update someones post' do
      sign_in users[:user]
      post = create :post, post_attrs
      patch :update, id: post.id, post: post_params
      post_not_updated post
    end

    it 'admin should update someones post' do
      sign_in users[:admin]
      post = create :post, post_attrs
      patch :update, id: post.id, post: post_params
      post_updated post
    end

    it 'moderator should update someones post' do
      sign_in users[:moderator]
      post = create :post, post_attrs
      patch :update, id: post.id, post: post_params
      post_updated post
    end

    it 'should save updated_at' do
      sign_in users[:admin]
      post = create :post, post_attrs
      time = Faker::Time.between 1.year.ago, 1.year.from_now
      Timecop.freeze time
      expect { patch :update, id: post.id, post: post_params }.to change { post.reload.updated_at.to_i }.to time.to_i
      Timecop.return
    end

    it 'should ignore not permitted attrs' do
      sign_in users[:admin]
      post = create :post, post_attrs
      old_id = post.id.freeze
      patch :update, id: post.id, post: post_params.merge(id: (Post.last.try(:id) || 0) + 1)
      post_updated post
      expect(post.id).to eq old_id
    end

    it 'should not update w/wrong post id' do
      sign_in users[:admin]
      post = create :post, post_attrs
      patch :update, id: ((Post.last.try(:id) || 0) + 1), post: post_params
      post_not_updated post
      expect(response).to have_http_status(404)
    end
    %i(title content).each { |attr_name| it_behaves_like 'update post', attr_name }
  end
end
