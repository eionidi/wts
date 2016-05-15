require 'rails_helper'

describe User do
  context 'validation' do
    it 'should not save user w/o email' do
      user = User.new name: Faker::Name.name
      expect(user.valid?).to be false
      expect(user.save).to be false
      expect(user.errors[:email]).not_to be_empty
    end
  end

  context 'method' do
    it "should return users's last post" do
      post = create :post, :with_user
      expect(post.author.last_post).to eq post
    end
  end
end
