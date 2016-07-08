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

      # it 'should not save comment w/o content' do
      #   comment_not_valid Comment.new(post: create(:post, :with_user), content: nil, author: create(:user)), :content
      # end

      # it 'should not save comment w/o author' do
      #   comment_not_valid Comment.new(post: create(:post, :with_user), content: Faker::Lorem.paragraph), :author
      # end

      # it 'should not save comment w/o post' do
      #   comment_not_valid Comment.new(content: Faker::Lorem.paragraph, author: create(:user)), :post
      # end

      # it 'should not save short comment' do
      #   comment_not_valid Comment.new(content: 'a' * 2, author: create(:user), post: create(:post, :with_user)), :content
      # end

      # it 'should not save long comment' do
      #   comment_not_valid Comment.new(content: 'a' * 1030, author: create(:user), post: create(:post, :with_user)), :content
      # end

      # it 'should save comment w/minimal content' do
      #   comment_valid Comment.new(content: 'a' * 3, author: create(:user), post: create(:post, :with_user))
      # end

      # it 'should save comment w/maximum content' do
      #   comment_valid Comment.new(content: 'a' * 1024, author: create(:user), post: create(:post, :with_user))
      # end
    end
  end

  context 'association' do
    describe 'comments' do
      it { should belong_to(:author) }
      it { should belong_to(:post) }
      # TODO: add last_updated_by association

      # it 'should return comment author' do
      #   user = create :user, :user
      #   comment = create :comment, author: user
      #   expect(comment.author).to eq user
      # end

      # it 'should return commented post' do
      #   post = create(:post, :with_user)
      #   comment = create :comment, :with_user, post: post
      #   expect(comment.post).to eq post
      # end

      # TODO: remove
      it 'should return user of last comment' do
        first_user = create :user
        last_user = create :user
        comment_first = create :comment, author: first_user
        comment_last = create :comment, author: last_user
        expect(comment_last.author).to eq last_user
      end
    end
  end

  context 'method' do
    describe 'last_actor' do
      # TODO: use User instaed of User.name
      # TODO: uncovered case: returned value is last_updated_by
      it 'should return author name' do
        user = create :user, :user
        comment = create :comment, author: user
        expect(comment.last_actor.name).to eq user.name
      end
    end
  end
end
