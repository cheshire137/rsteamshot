require 'spec_helper'

RSpec.describe Rsteamshot::ScreenshotPaginator do
  context '#steam_page_and_offset' do
    it 'returns given page and 0 when per page is MAX_PER_PAGE' do
      steam_page, offset = described_class.new(1, 50).steam_page_and_offset
      expect(steam_page).to eq(1)
      expect(offset).to eq(0)

      steam_page, offset = described_class.new(3, 50).steam_page_and_offset
      expect(steam_page).to eq(3)
      expect(offset).to eq(0)
    end

    it 'returns correct values for first page of Steam results' do
      steam_page, offset = described_class.new(2, 3).steam_page_and_offset
      expect(steam_page).to eq(1)
      expect(offset).to eq(3)

      steam_page, offset = described_class.new(3, 3).steam_page_and_offset
      expect(steam_page).to eq(1)
      expect(offset).to eq(6)

      steam_page, offset = described_class.new(4, 10).steam_page_and_offset
      expect(steam_page).to eq(1)
      expect(offset).to eq(30)

      steam_page, offset = described_class.new(1, 40).steam_page_and_offset
      expect(steam_page).to eq(1)
      expect(offset).to eq(0)

      steam_page, offset = described_class.new(1, 30).steam_page_and_offset
      expect(steam_page).to eq(1)
      expect(offset).to eq(0)

      steam_page, offset = described_class.new(2, 30).steam_page_and_offset
      expect(steam_page).to eq(1)
      expect(offset).to eq(30)
    end

    it 'returns correct values for later pages of Steam results' do
      steam_page, offset = described_class.new(3, 30).steam_page_and_offset
      expect(steam_page).to eq(2)
      expect(offset).to eq(10)

      steam_page, offset = described_class.new(4, 30).steam_page_and_offset
      expect(steam_page).to eq(2)
      expect(offset).to eq(20)

      steam_page, offset = described_class.new(5, 30).steam_page_and_offset
      expect(steam_page).to eq(4)
      expect(offset).to eq(0)
    end
  end
end
