require 'rails_helper'

describe ApplicationHelper, type: :helper do
  describe '#format_datetime' do
    it 'should return correct datetime' do
      time = Faker::Time.between 1.year.ago, 1.year.from_now
      expect(helper.format_datetime time).to eq time.strftime '%H:%M %d.%m.%Y'
    end
    it 'should return nil' do
      expect(helper.format_datetime nil).to be nil
    end
  end
end
