require 'rails_helper'

describe Post do
  context 'validation' do
    def user_not_valid(post, wrong_attr)
      expect(post.valid?).to be false
      expect(post.save).to be false
      expect(post.errors[wrong_attr]).not_to be_empty
    end

    def post_valid(post)
      expect(post.valid?).to be true
      expect(post.save).to be true
      expect(post.errors).to be_empty
    end

	describe 'author name ' do
	  it 'should not save post w/o author' do
	    post_not_valid Post.new(trait :with_user), :author
      end
	end
  end
end
