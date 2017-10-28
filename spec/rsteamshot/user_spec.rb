require 'spec_helper'

RSpec.describe Rsteamshot::User do
  subject(:user) { described_class.new('cheshire137') }

  context '#screenshots' do
    it 'returns screenshots' do
      VCR.use_cassette('user_screenshots') do
        result = user.screenshots

        expect(result).to_not be_empty
        result.each do |screenshot|
          expect(screenshot).to be_an_instance_of(Rsteamshot::Screenshot)
        end
      end
    end
  end
end
