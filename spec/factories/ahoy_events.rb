# frozen_string_literal: true

FactoryBot.define do
  factory :ahoy_event, class: 'Ahoy::Event' do
    visit { association :ahoy_visit }
    properties { { druid: 'bb051dp0564' } }

    trait :view do
      name { '$view' }
    end

    trait :download do
      name { 'download' }
    end
  end
end
