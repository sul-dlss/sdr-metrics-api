# frozen_string_literal: true

require 'rails_helper'

RSpec.describe 'metrics request' do
  let(:druid) { 'bb051dp0564' }
  let(:visit) { Ahoy::Visit.create(started_at: Time.zone.now) }

  before do
    5.times { Ahoy::Event.create(visit:, name: '$view', properties: { druid: }) }
    2.times { Ahoy::Event.create(visit:, name: 'download', properties: { druid: }) }
  end

  it 'returns metrics for a given druid' do
    get metrics_path druid:, format: :json
    expect(response.body).to eq(
      { views: 5, downloads: 2, unique_views: 1, unique_downloads: 1 }.to_json
    )
  end
end
