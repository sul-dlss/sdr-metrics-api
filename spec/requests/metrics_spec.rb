# frozen_string_literal: true

require 'rails_helper'

RSpec.describe 'metrics request' do
  let(:druid) { 'bb051dp0564' }
  let(:visit) { create(:ahoy_visit) }

  before do
    create_list(:ahoy_event, 5, :view, visit:)
    create_list(:ahoy_event, 2, :download, visit:)
  end

  it 'returns metrics for a given druid' do
    get metrics_path druid:, format: :json
    expect(response.body).to eq(
      { views: 5, downloads: 2, unique_views: 1, unique_downloads: 1 }.to_json
    )
  end
end
