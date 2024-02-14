# frozen_string_literal: true

module Ahoy
  # A single event triggered by a client, like a view or download
  class Event < ApplicationRecord
    include Ahoy::QueryMethods

    self.table_name = 'ahoy_events'

    belongs_to :visit

    serialize :properties, coder: JSON

    before_save { self.druid = properties['druid'] }
  end
end
