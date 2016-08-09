source "https://rubygems.org"

branch = ENV.fetch('SOLIDUS_BRANCH', 'master')
gem "solidus", github: "solidusio/solidus", branch: branch

# ActiveMerchant v1.58 through v1.59 introduced a breaking change
# to the stripe gateway.
#
# This was resolved in v1.60, but we still need to skip 1.58 & 1.59.
gem "activemerchant", "~> 1.48", "!= 1.58.0", "!= 1.59.0", github: "dynamomtl/active_merchant_new", branch: 'feature/shopify/prototype-implementation'

group :development, :test do
  gem "pry-rails"
end

gem 'pg'
gem 'mysql2'

gemspec
