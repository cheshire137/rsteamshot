require 'spec_helper'

RSpec.describe Rsteamshot::Screenshot do
  let(:title) { 'A NEW HAND TOUCHED THE BEACON' }
  let(:details_url) { 'http://steamcommunity.com/sharedfiles/filedetails/?id=789436652' }
  let(:full_size_url) { 'https://steamuserimages-a.akamaihd.net/ugc/230074563809665585/590A645C1B9155C2742484ED2B66F60CE2A62DD8/' }
  let(:medium_url) { 'https://steamuserimages-a.akamaihd.net/ugc/230074563809665585/590A645C1B9155C2742484ED2B66F60CE2A62DD8/?interpolation=lanczos-none&output-format=jpeg&output-quality=95&fit=inside|1024:576&composite-to%3D%2A%2C%2A%7C1024%3A576&background-color=black' }
  let(:user_name) { 'cheshire137' }
  let(:user_url) { 'http://steamcommunity.com/id/cheshire137' }
  let(:date) { DateTime.parse('2016-10-29 9:45') }
  let(:file_size) { '0.547 MB' }
  let(:like_count) { 0 }
  let(:comment_count) { 0 }
  let(:width) { 3840 }
  let(:height) { 2160 }
  let(:app) {
    Rsteamshot::App.new(id: '489830', name: 'The Elder Scrolls V: Skyrim Special Edition')
  }
  subject(:screenshot) {
    VCR.use_cassette('screenshot_get_details') do
      described_class.new(title: title, details_url: details_url)
    end
  }

  it 'uses given title' do
    expect(screenshot.title).to eq(title)
  end

  it 'uses given details URL' do
    expect(screenshot.details_url).to eq(details_url)
  end

  it 'populates additional details on initialization' do
    expect(screenshot.full_size_url).to eq(full_size_url)
    expect(screenshot.medium_url).to eq(medium_url)
    expect(screenshot.user_name).to eq(user_name)
    expect(screenshot.user_url).to eq(user_url)
    expect(screenshot.date).to eq(date)
    expect(screenshot.file_size).to eq(file_size)
    expect(screenshot.width).to eq(width)
    expect(screenshot.height).to eq(height)
    expect(screenshot.like_count).to eq(like_count)
    expect(screenshot.comment_count).to eq(comment_count)
    expect(screenshot.app).to eq(app)
  end

  context "#to_h" do
    it 'returns a hash of screenshot data' do
      expected = {
        title: title,
        details_url: details_url,
        full_size_url: full_size_url,
        medium_url: medium_url,
        width: width,
        height: height,
        file_size: file_size,
        user_name: user_name,
        user_url: user_url,
        date: date,
        like_count: like_count,
        comment_count: comment_count
      }

      expect(screenshot.to_h).to eq(expected)
    end
  end

  context '#to_json' do
    it 'returns a string of JSON' do
      result = screenshot.to_json

      expect(result).to be_an_instance_of(String)

      json = JSON.parse(result)
      expect(json['details_url']).to eq(details_url)
      expect(json['title']).to eq(title)
      expect(json['full_size_url']).to eq(full_size_url)
      expect(json['medium_url']).to eq(medium_url)
      expect(json['user_name']).to eq(user_name)
      expect(json['user_url']).to eq(user_url)
      expect(json['date']).to eq(date.iso8601)
      expect(json['file_size']).to eq(file_size)
      expect(json['width']).to eq(width)
      expect(json['height']).to eq(height)
      expect(json['like_count']).to eq(like_count)
      expect(json['comment_count']).to eq(comment_count)
    end
  end
end
