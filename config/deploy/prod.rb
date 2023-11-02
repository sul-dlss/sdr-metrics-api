# frozen_string_literal: true

server 'metrics-prod-a.stanford.edu', user: 'metrics', roles: %w[app]

Capistrano::OneTimeKey.generate_one_time_key!
set :rails_env, 'production'
