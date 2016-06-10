require 'rails_helper'
require "#{Rails.root}/lib/my_artec_checker"

describe MyArtecChecker do
  let(:checker) { MyArtecChecker.new }

  around(:example) do |example|
    WebMock.enable!
    example.run
    WebMock.disable!
  end

  describe '#check_user' do
    it 'should return false' do
      email = 'asdfasdf'
      stub_request(:get, "https://staging-booth-my.artec3d.com/users/exist.json?user%5Bemail%5D=#{email}").
        to_return(status: 200, body: { 'exist' => false }.to_json)
      expect(JSON.parse(checker.check_user(email))).to eq({ 'exist' => false })
    end
    it 'should return true' do
      email = 'malexeev@artec-group.com'
      stub_request(:get, "https://staging-booth-my.artec3d.com/users/exist.json?user%5Bemail%5D=#{email}").
        to_return(status: 200, body: { 'exist' => true }.to_json)
      expect(JSON.parse(checker.check_user('malexeev@artec-group.com'))).to eq({ 'exist' => true })
    end
  end
end
