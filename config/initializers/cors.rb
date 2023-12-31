# Be sure to restart your server when you modify this file.

# Avoid CORS issues when API is called from the frontend app.
# Handle Cross-Origin Resource Sharing (CORS) in order to accept cross-origin Ajax requests.

# Read more: https://github.com/cyu/rack-cors

# Note that this is handled by puppet in deployed environments – this configuration
# only affects local development.

Rails.application.config.middleware.insert_before 0, Rack::Cors do
  allow do
    origins "/stanford.edu\z"

    resource "*",
      headers: :any,
      methods: [:get, :post, :put, :patch, :delete, :options, :head]
  end
end
