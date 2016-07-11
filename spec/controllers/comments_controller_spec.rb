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
      stub_request(:get, "https://staging-booth-my.artec3d.com/users/exist.json?user%5Bemail%5D=#{comment.last_actor.email}").
      to_return(status: 200, body: { 'exist' => false }.to_json)
      get :show, id: comment.id, post_id: comment.post.id
      #xhr :get, :show, id: comment.id, post_id: comment.post.id
      expect(response).to have_http_status(200).and render_template 'show'
      expect(response.body).to match comment.content
      expect(controller.instance_variable_get('@comment')).to eq comment
    end
  end

  describe '#show' do
    User.roles.keys.each { |role| it_behaves_like 'show comment', role }

    it 'should return 404 w/wrong comment id' do
      sign_in users.values.sample
      comment = comments.values.each(&:reload).sample
      stub_request(:get, "https://staging-booth-my.artec3d.com/users:80").
      to_return(status: 200, body: { 'exist' => false }.to_json)
      #comments.values.each(&:reload)
      #get :show, id: Comment.last.id + 1, post_id: comment.post.id
      get :show, id: (Comment.last.try(:id) || 0) + 1, post_id: comment.post.id
      expect(response).to have_http_status(404)
    end
  end

  shared_examples 'create comment' do |role|
    it "with role '#{role}'" do
      sign_in users[role.to_sym]
      post = posts.values.each(&:reload).sample
      expect { post(:create, post_id: post.id, comment: comment_params) }.to change { Comment.count }.by 1
      comment = Comment.last
      expect(response).to redirect_to "/posts/#{comment.post.id}"
      expect(flash.now[:notice]).to eq "Comment ##{comment.id} created!"
      expect(comment.author).to eq users[role.to_sym]
    end
  end

  # TODO: add test for invalid content
  describe '#create' do
    User.roles.keys.each { |role| it_behaves_like 'create comment', role }


    it 'should save with attach' do
      sign_in users.values.sample
      post = posts.values.each(&:reload).sample
      expect { post(:create, post_id: post.id, comment: comment_params.merge(file_attach: fixture_file_upload('fixtures/post_image.png', 'image/png'))) }.
        to change { Comment.count }.by 1
      expect(Comment.last.file_attach).to be_exists
    end
  end

  describe '#destroy' do
    it 'admin should destroy comment' do
      sign_in users[:admin]
      comment = create :comment, :with_user
      stub_request(:get, "https://staging-booth-my.artec3d.com/users/exist.json?user%5Bemail%5D=#{comment.last_actor.email}").
      to_return(status: 200, body: { 'exist' => false }.to_json)
      expect { delete :destroy, post_id: comment.post.id, id: comment.id }.to change { Comment.count }.by -1
      expect(response).to redirect_to "/posts/#{comment.post.id}"
    end

    it 'admin should not destroy comment w/wrong id' do
      sign_in users[:admin]
      comment = create :comment, author: users[:admin]
      stub_request(:get, "https://staging-booth-my.artec3d.com/users:80").
      to_return(status: 200, body: { 'exist' => false }.to_json)
      expect { delete :destroy, id: (Comment.last.try(:id) || 0) + 1, post_id: comment.post.id }.to not_change { Comment.count }
      expect(response).to have_http_status(404)
    end

    it 'user should not destroy comment' do
      sign_in users[:user]
      comment = create :comment, author: users[:user]
      stub_request(:get, "https://staging-booth-my.artec3d.com/users/exist.json?user%5Bemail%5D=#{comment.last_actor.email}").
      to_return(status: 200, body: { 'exist' => false }.to_json)
      expect { delete :destroy, post_id: comment.post.id, id: comment.id }.to not_change { Comment.count }
      expect(response).to redirect_to '/'
    end

    it 'moderator should not destroy post' do
      sign_in users[:moderator]
      comment = create :comment, author: users[:moderator]
      stub_request(:get, "https://staging-booth-my.artec3d.com/users/exist.json?user%5Bemail%5D=#{comment.last_actor.email}").
      to_return(status: 200, body: { 'exist' => false }.to_json)
      expect { delete :destroy, post_id: comment.post.id, id: comment.id }.to not_change { Comment.count }
      expect(response).to redirect_to '/'
    end
  end

  shared_examples 'update comment' do |attr_name|
    it "with empty '#{attr_name}'" do
      sign_in users[:admin]
      comment = create :comment, comment_attrs
      stub_request(:get, "https://staging-booth-my.artec3d.com/users/exist.json?user%5Bemail%5D=#{comment.last_actor.email}").
      to_return(status: 200, body: { 'exist' => false }.to_json)
      patch :update, id: comment.id, comment: comment_params.merge(attr_name => ''), post_id: comment.post.id
      comment.reload
      expect(comment.content).to eq comment_attrs[:content]
      expect(response).to render_template 'edit'
      expect(flash[:error]).not_to be_empty
    end
  end

  # shared_examples'update own comment' do |role|
  #   it "with role '#{role}'" do
  #     sign_in users[role.to_sym]
  #     comment = create :comment, :author[users]
  #     stub_request(:get, "https://staging-booth-my.artec3d.com/users/exist.json?user%5Bemail%5D=#{comment.last_actor.email}").
  #     to_return(status: 200, body: { 'exist' => false }.to_json)
  #     patch :update, id: comment[role.to_sym].id, comment: comment_params, post_id: comment.post.id
  #     comment.reload
  #     expect(comment.content).to eq comment_params[:content]
  #     expect(response).to redirect_to "/posts/#{comment.post.id}"
  #     #expect(flash[:notice]).to eq "Comment ##{@comment.id} updated!"
  #   end
  # end

  # describe '#update' do
  #   User.roles.keys.each { |role| it_behaves_like 'update own comment', role }

  # TODO: shared examples
  # TODO: add test for 'User can edit any Comments at his Post'
  describe '#update' do
    it "should update own comment by admin" do
      sign_in users[:admin]
      comment = create :comment, author: users[:admin]
      stub_request(:get, "https://staging-booth-my.artec3d.com/users/exist.json?user%5Bemail%5D=#{comment.last_actor.email}").
      to_return(status: 200, body: { 'exist' => false }.to_json)
      patch :update, id: comment.id, comment: comment_params, post_id: comment.post.id
      comment.reload
      expect(comment.content).to eq comment_params[:content]
      expect(response).to redirect_to "/posts/#{comment.post.id}"
    end

    it "should update own comment by moderator" do
      sign_in users[:moderator]
      comment = create :comment, author: users[:moderator]
      stub_request(:get, "https://staging-booth-my.artec3d.com/users/exist.json?user%5Bemail%5D=#{comment.last_actor.email}").
      to_return(status: 200, body: { 'exist' => false }.to_json)
      patch :update, id: comment.id, comment: comment_params, post_id: comment.post.id
      comment.reload
      expect(comment.content).to eq comment_params[:content]
      expect(response).to redirect_to "/posts/#{comment.post.id}"
    end

    it "should update own comment by user" do
      sign_in users[:user]
      comment = create :comment, author: users[:user]
      stub_request(:get, "https://staging-booth-my.artec3d.com/users/exist.json?user%5Bemail%5D=#{comment.last_actor.email}").
      to_return(status: 200, body: { 'exist' => false }.to_json)
      patch :update, id: comment.id, comment: comment_params, post_id: comment.post.id
      comment.reload
      expect(comment.content).to eq comment_params[:content]
      expect(response).to redirect_to "/posts/#{comment.post.id}"
    end

    it 'user should not update someones comment' do
      sign_in users[:user]
      comment = create :comment, comment_attrs
      stub_request(:get, "https://staging-booth-my.artec3d.com/users/exist.json?user%5Bemail%5D=#{comment.last_actor.email}").
      to_return(status: 200, body: { 'exist' => false }.to_json)
      patch :update, id: comment.id, comment: comment_params, post_id: comment.post.id
      comment.reload
      expect(comment.content).to eq comment_attrs[:content]
    end

    it 'admin should update someones comment' do
      sign_in users[:admin]
      comment = create :comment, comment_attrs
      stub_request(:get, "https://staging-booth-my.artec3d.com/users/exist.json?user%5Bemail%5D=#{comment.last_actor.email}").
      to_return(status: 200, body: { 'exist' => false }.to_json)
      patch :update, id: comment.id, comment: comment_params, post_id: comment.post.id
      expect(comment.reload.content).to eq comment_params[:content]
      expect(response).to redirect_to "/posts/#{comment.post.id}"
      expect(flash[:notice]).to eq "Comment ##{comment.id} updated!"
    end

    it 'moderator should update someones comment' do
      sign_in users[:moderator]
      comment = create :comment, comment_attrs
      stub_request(:get, "https://staging-booth-my.artec3d.com/users/exist.json?user%5Bemail%5D=#{comment.last_actor.email}").
      to_return(status: 200, body: { 'exist' => false }.to_json)
      patch :update, id: comment.id, comment: comment_params, post_id: comment.post.id
      comment.reload
      expect(comment.content).to eq comment_params[:content]
      expect(response).to redirect_to "/posts/#{comment.post.id}"
      expect(flash[:notice]).to eq "Comment ##{comment.id} updated!"
    end

    # TODO: add test for last_updated_by
    it 'should save updated_at' do
      sign_in users[:admin]
      comment = create :comment, comment_attrs
      stub_request(:get, "https://staging-booth-my.artec3d.com/users/exist.json?user%5Bemail%5D=#{comment.last_actor.email}").
      to_return(status: 200, body: { 'exist' => false }.to_json)
      time = Faker::Time.between 1.year.ago, 1.year.from_now
      Timecop.freeze time
      expect { patch :update, id: comment.id, post_id: comment.post.id, comment: comment_params }.to change { comment.reload.updated_at.to_i }.to time.to_i
      Timecop.return
    end

    it 'should ignore not permitted attrs' do
      sign_in users[:admin]
      comment = create :comment, comment_attrs
      stub_request(:get, "https://staging-booth-my.artec3d.com/users/exist.json?user%5Bemail%5D=#{comment.last_actor.email}").
      to_return(status: 200, body: { 'exist' => false }.to_json)
      old_id = comment.id.freeze
      patch :update, id: comment.id, post_id: comment.post.id, comment: comment_params.merge(id: (Comment.last.try(:id) || 0) + 1)
      comment.reload
      expect(comment.content).to eq comment_params[:content]
      expect(response).to redirect_to "/posts/#{comment.post.id}"
      expect(flash[:notice]).to eq "Comment ##{comment.id} updated!"
      expect(comment.id).to eq old_id
    end

    it 'should not update w/wrong comment id' do
      sign_in users[:admin]
      comment = create :comment, comment_attrs
      stub_request(:get, "https://staging-booth-my.artec3d.com/users/exist.json?user%5Bemail%5D=#{comment.last_actor.email}").
      to_return(status: 200, body: { 'exist' => false }.to_json)
      patch :update, id: ((Comment.last.try(:id) || 0) + 1), comment: comment_params, post_id: comment.post.id
      comment.reload
      expect(comment.content).to eq comment_attrs[:content]
      expect(response).to have_http_status(404)
    end
    %i(content).each { |attr_name| it_behaves_like 'update comment', attr_name }
  end
end
