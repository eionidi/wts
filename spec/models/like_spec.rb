require 'rails_helper'

describe Like do
  # context 'validation' do
  #   # def like_not_valid(like, wrong_attr)
  #   #   expect(like.valid?).to be false
  #   #   expect(like.save).to be false
  #   #   expect(like.errors[wrong_attr]).not_to be_empty
  #   # end

  #   # def like_valid(like)
  #   #   expect(like.valid?).to be true
  #   #   expect(like.save).to be true
  #   #   expect(like.errors).to be_empty
  #   # end

  #   describe 'like' do
  #     it { should validate_presence_of :author }
  #     it { should validate_presence_of :post }
  #   end
  # end

  context 'association' do
    describe 'like' do
      it { should belong_to(:user) }
      it { should belong_to(:post) }
    end
  end
end
