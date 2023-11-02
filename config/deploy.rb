# frozen_string_literal: true

set :application, 'metrics'
set :repo_url, 'https://github.com/sul-dlss/sdr-metrics-api.git'

# Default branch is :master so we need to update to main
if ENV['DEPLOY']
  set :branch, 'main'
else
  ask :branch, proc { `git rev-parse --abbrev-ref HEAD`.chomp }.call
end

# Default deploy_to directory is /var/www/my_app
set :deploy_to, '/opt/app/metrics/metrics'

# Default value for :linked_files is []
set :linked_files, %w(config/database.yml public/robots.txt)

# Default value for linked_dirs is []
set :linked_dirs, %w(config/settings log tmp/pids tmp/cache tmp/sockets vendor/bundle)
