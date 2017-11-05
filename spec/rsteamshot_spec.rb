require 'spec_helper'

RSpec.describe Rsteamshot do
  it 'has a version number' do
    expect(Rsteamshot::VERSION).not_to be nil
  end

  describe 'configuration' do
    before do
      Rsteamshot.configure do |config|
        config.apps_list_path = 'some/file/path.json'
      end
    end

    it 'remembers path to apps list' do
      config = Rsteamshot.configuration
      expect(config.apps_list_path).to eq('some/file/path.json')
    end
  end
end
