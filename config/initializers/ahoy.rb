class Ahoy::Store < Ahoy::DatabaseStore
end

# events are only tracked via incoming API requests; we create a visit object
# when the first event for a new visit is tracked
Ahoy.api = true
Ahoy.api_only = true
Ahoy.server_side_visits = :when_needed

# mask IPs by setting the last octet to 0
Ahoy.mask_ips = true

# enable event logging in development
Ahoy.quiet = !Rails.env.development?

# set to true for geocoding (and add the geocoder gem to your Gemfile)
# ahoy recommends configuring local geocoding as well
# see https://github.com/ankane/ahoy#geocoding
Ahoy.geocode = false
