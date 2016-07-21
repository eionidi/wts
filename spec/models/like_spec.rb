require 'rails_helper'

describe Like do
  context 'association' do
    describe 'like' do
      it { should belong_to(:user) }
      it { should belong_to(:post) }
    end
  end
end
