require 'rails_helper'

describe PostsController do
  let(:user) { create(:user) }

  describe '#create' do
    it 'should save with image' do
      sign_in user
      expect { post :create,
               post: { title: Faker::Lorem.sentence,
                       content: Faker::Lorem.paragraph,
                       author_id: user.id,
                       image: fixture_file_upload('fixtures/post_image.png', 'image/png') } }.
        to change { Post.count }.by 1
      expect(Post.last.image).to be_exists
    end
  end
end