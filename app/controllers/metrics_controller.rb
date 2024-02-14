# frozen_string_literal: true

# API for querying metrics for a given druid
class MetricsController < ApplicationController
  def show
    render json: {
      views: views.count,
      downloads: downloads.count,
      unique_views: views.distinct.count(:visit_id),
      unique_downloads: downloads.distinct.count(:visit_id)
    }
  end

  private

  def views
    Ahoy::Event.where(name: '$view', druid: params[:druid])
  end

  def downloads
    Ahoy::Event.where(name: 'download', druid: params[:druid])
  end
end
