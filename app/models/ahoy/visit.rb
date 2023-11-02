# frozen_string_literal: true

module Ahoy
  # A session started on the client, consisting of a stream of events
  class Visit < ApplicationRecord
    self.table_name = 'ahoy_visits'

    has_many :events, class_name: 'Ahoy::Event', dependent: :nullify
  end
end
