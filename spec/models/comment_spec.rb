require 'rails_helper'

describe Comment do
  context 'validation' do
    def comment_not_valid(comment, wrong_attr)
      expect(comment.valid?).to be false
      expect(comment.save).to be false
      expect(comment.errors[wrong_attr]).not_to be_empty
    end

    def comment_valid(comment)
      expect(comment.valid?).to be true
      expect(comment.save).to be true
      expect(comment.errors).to be_empty
    end
    
    describe 'comments' do
      it { should validate_presence_of :content }
      it { should validate_presence_of :author }
      it { should validate_presence_of :post }
      it { should validate_length_of(:content).is_at_least(3) }
      it { should validate_length_of(:content).is_at_most(1024) }
      it { should_not allow_value('a' * 2).for(:content) }
      it { should_not allow_value('a' * 1030).for(:content) }
    end
  end

  context 'association' do
    describe 'comments' do
      it { should belong_to(:author) }
      it { should belong_to(:post) }
      it { should belong_to(:last_updated_by)}
    end
  end

  context 'method' do
    describe 'last_actor' do
     
      it 'should return author name' do
        user = create :user, :user
        comment = create :comment, author: user
        expect(comment.last_actor).to eq user
      end

      it 'should return last author name updated comment' do
        post = create :post, :with_user
        user_first = create :user, :user
        comment = create :comment, author: user_first, post: post
        user_last = create :user, :user
        comment_updated = update :comment, author: user_last, post: post
        expect(comment_updated.last_updated_by).to eq user_last
      end
    end
  end
end
