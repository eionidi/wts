require 'rails_helper'
RSpec::Matchers.define_negated_matcher :not_change, :change

describe CommentsController do
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
  let(:comments) do
    {
      user: create(:comment, author: users[:user], post: posts[:user]),
      moderator: create(:comment, author: users[:moderator], post: posts[:moderator]),
      admin: create(:comment, author: users[:admin], post: posts[:admin])
    }
  end
  let(:comment_attrs) do
    {
      content: Faker::Lorem.paragraph,
      author: create(:user),
      post: create(:post, :with_user)
    }
  end
  let(:comment_params) do
    {
      content: Faker::Lorem.paragraph
    }
  end

  shared_examples 'show comment' do |role|
    it "with role '#{role}'" do
      sign_in users[role.to_sym]
      comment = comments.values.each(&:reload).sample
      get :show, id: comment.id
      expect(response).to have_http_status(200).and render_template 'show'
      expect(response.body).to match comment.content
      expect(controller.instance_variable_get('@comment')).to eq post
    end
  end

  describe '#show' do
    User.roles.keys.each { |role| it_behaves_like 'show comment', role }

    it 'should return 404 w/wrong comment id' do
      sign_in users.values.sample
      # comments.values.each(&:reload)
      # get :show, id: Comment.last.id + 1
      get :show, id: (Comment.last.try(:id) || 0) + 1
      expect(response).to have_http_status(404)
    end

    it 'should redirect to My Artec' do
    # ???
      stub_request(:get, "http://www.staging-booth-my.artec3d.com/users:80/").
         with(:headers => {'Accept'=>'*/*', 'Accept-Encoding'=>'gzip;q=1.0,deflate;q=0.6,identity;q=0.3', 'User-Agent'=>'Ruby'}).
         to_return(:status => 200, :body => "", :headers => {})
    end
  end

  shared_examples 'create comment' do |role|
    it "with role '#{role}'" do
      sign_in users[role.to_sym]
      expect { post :create, comment: comment_attrs }.to change { Comment.count }.by 1
      comment = Comment.last
      expect(response).to redirect_to "posts/#{post.id}"
      expect(flash.now[:notice]).to eq "Comment ##{@comment.id} created!"
      expect(comment.author).to eq users[role.to_sym]
    end
  end

  describe '#create' do
    User.roles.keys.each { |role| it_behaves_like 'create comment', role }

    it 'should save with attach' do
      sign_in users.values.sample
      expect { post :create,
               comment: comment_attrs.merge(image: fixture_file_upload('fixtures/post_image.png', 'image/png')) }.
        to change { Comment.count }.by 1
      expect(Comment.last.image).to be_exists
    end
  end

  describe '#destroy' do
    it 'admin should destroy comment' do
      sign_in users[:admin]
      comment = create :comment, :with_user
      expect { delete :destroy, id: comment.id }.to change { Comment.count }.by -1
      expect(response).to redirect_to '/posts'
    end

    it 'admin should not destroy comment w/wrong id' do
      sign_in users[:admin]
      comments.values.each(&:reload)
      expect { delete :destroy, id: (Comment.last.try(:id) || 0) + 1 }.to not_change { Comment.count }
      expect(response).to have_http_status(404)
    end

    it 'user should not destroy comment' do
      sign_in users[:user]
      comment = create :comment, :with_user
      expect { delete :destroy, id: comment.id }.to not_change { Comment.count }
      expect(response).to redirect_to '/'
    end

    it 'moderator should not destroy post' do
      sign_in users[:moderator]
      comment = create :comment, :with_user
      expect { delete :destroy, id: comment.id }.to not_change { Comment.count }
      expect(response).to redirect_to '/'
    end
  end

  shared_examples 'update comment' do |attr_name|
    it "with empty '#{attr_name}'" do
      sign_in users[:admin]
      comment = create :comment, comment_attrs
      patch :update, id: comment.id, comment: comment_params.merge(attr_name => '')
      comment.reload
      expect(comment.content).to eq comment_attrs[:content]
      expect(response).to render_template 'edit'
      expect(flash[:error]).not_to be_empty
    end
  end

  shared_examples'update own comment' do |role|
    it "with role '#{role}'" do
      sign_in users[role.to_sym]
      comment = create :comment, comment_attrs
      patch :update, id: comments[role.to_sym].id, comment: comment_params
      post.reload
      expect(comment.content).to eq comment_params[:content]
      expect(response).to redirect_to "/posts/#{post.id}"
      expect(flash[:notice]).to eq "Comment ##{@comment.id} updated!"
    end
  end

  describe '#update' do
    User.roles.keys.each { |role| it_behaves_like 'update own comment', role }

    it 'user should not update someones comment' do
      sign_in users[:user]
      comment = create :comment, comment_attrs
      patch :update, id: comment.id, comment: comment_params
      comment.reload
      expect(comment.content).to eq comment_attrs[:content]
    end

    it 'admin should update someones comment' do
      sign_in users[:admin]
      comment = create :comment, comment_attrs
      patch :update, id: comment.id, comment: comment_params
      post.reload
      expect(comment.content).to eq comment_params[:content]
      expect(response).to redirect_to "/posts/#{post.id}"
      expect(flash[:notice]).to eq "Comment ##{@comment.id} updated!"
    end

    it 'moderator should update someones comment' do
      sign_in users[:moderator]
      comment = create :comment, comment_attrs
      patch :update, id: comment.id, comment: comment_params
      post.reload
      expect(comment.content).to eq comment_params[:content]
      expect(response).to redirect_to "/posts/#{post.id}"
      expect(flash[:notice]).to eq "Comment ##{@comment.id} updated!"
    end

    it 'should save updated_at' do
      sign_in users[:admin]
      comment = create :comment, comment_attrs
      time = Faker::Time.between 1.year.ago, 1.year.from_now
      Timecop.freeze time
      expect { patch :update, id: comment.id, comment: comment_params }.to change { comment.reload.updated_at.to_i }.to time.to_i
      Timecop.return
    end

    it 'should ignore not permitted attrs' do
      sign_in users[:admin]
      comment = create :comment, comment_attrs
      old_id = comment.id.freeze
      patch :update, id: comment.id, comment: comment_params.merge(id: (Comment.last.try(:id) || 0) + 1)
      post.reload
      expect(post.content).to eq post_params[:content]
      expect(response).to redirect_to "/posts/#{post.id}"
      expect(flash[:notice]).to eq "Comment ##{@comment.id} updated!"
      expect(comment.id).to eq old_id
    end

    it 'should not update w/wrong comment id' do
      sign_in users[:admin]
      comment = create :comment, comment_attrs
      patch :update, id: ((Comment.last.try(:id) || 0) + 1), comment: comment_params
      post.reload
      expect(comment.content).to eq comment_attrs[:content]
      expect(response).to have_http_status(404)
    end
    %i(title content).each { |attr_name| it_behaves_like 'update comment', attr_name }
  end
end
