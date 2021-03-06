require 'rails_helper'
require "#{Rails.root}/lib/my_artec_checker"

describe MyArtecChecker do
  let(:checker) { MyArtecChecker.new }

  describe '#check_user' do
    it 'should return false' do
      email = 'asdfasdf'
      stub_request(:get, "https://staging-booth-my.artec3d.com/users/exist.json?user%5Bemail%5D=#{email}").
        to_return(status: 200, body: { 'exist' => false }.to_json)
      expect(checker.check_user(email)).to be_nil
    end
    it 'should return true' do
      email = 'malexeev@artec-group.com'
      stub_request(:get, "https://staging-booth-my.artec3d.com/users/exist.json?user%5Bemail%5D=#{email}").
        to_return(status: 200, body: { 'exist' => true }.to_json)
      expect(checker.check_user(email)).not_to be_nil
    end
  end
end
