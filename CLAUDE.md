# Shortstop URL Shortener Guide

## Commands
- Start server: `rails server` or `rails s`
- Console: `rails console` or `rails c`
- Run all tests: `bundle exec rspec`
- Run specific test: `bundle exec rspec spec/models/url_spec.rb`
- Lint: `bundle exec rubocop`
- Security scan: `bundle exec brakeman`
- Dependency CVEs: `bundle exec bundler-audit check --update`
- Database setup: `rails db:create db:migrate`
- Reset database: `rails db:drop db:create db:migrate`
- Create new migration: `rails g migration MigrationName`
- Everything in Docker: `make docker-up` (see `make help`)

## Local prerequisites
- Ruby 3.4.10, PostgreSQL, Bundler
- No Node.js and no JavaScript build step; the front end is served through
  importmap-rails.

## Authentication Setup
- OAuth is optional; the Google button is hidden unless both are set.
  - GOOGLE_CLIENT_ID=[your_google_client_id]
  - GOOGLE_CLIENT_SECRET=[your_google_client_secret]
- Create these credentials at https://console.cloud.google.com/apis/credentials

## Test User Account
For local testing, `rails db:seed` creates a user with sample URLs and visit data:
- Email: admin@example.com (override with SEED_ADMIN_EMAIL)
- Password: password123 (override with SEED_ADMIN_PASSWORD)

## Code Style
- Indentation: 2 spaces
- Modern Ruby hash syntax: `key: value`
- RuboCop with `rubocop-rails-omakase` plus `rubocop-rspec` is the arbiter; run it
  before committing
- Models: use validators and callbacks appropriately; behaviour that must always
  happen belongs in the model, not the controller
- Controllers: keep thin, use before_action filters
- Routes: RESTful with meaningful names. The catch-all short-link route must stay
  last and stay constrained to the Base62 alphabet, or it shadows real paths
- Views: extract shared markup into partials (`app/views/shared`, `_breakdown`)
- JavaScript: Stimulus controllers in `app/javascript/controllers`, no inline
  `<script>` blocks in templates
- URL validation: use the validate_url gem
- Base62 encoding and random slug generation: lib/base62.rb
- Error handling: use proper status codes and flash messages

## Project Architecture
A Rails 8.1 URL shortener using:
- PostgreSQL database
- Bootstrap 5 for frontend styling
- Hotwire (Turbo + Stimulus) served through importmap-rails, no build step
- Devise for authentication, OmniAuth for Google sign-in
- RSpec, FactoryBot, Capybara for testing
- GitHub Actions for CI (tests, RuboCop, Brakeman, bundler-audit)

## Domain notes
- A `Url` may have no user. Anonymous links are tracked against the browser
  session (`session[:url_ids]`), so the home page only ever shows the viewer
  their own links.
- `shortened_path` is a random 7-character Base62 slug generated in the model on
  create. It is deliberately *not* derived from the record id, which used to make
  every link on the service enumerable. Older id-derived slugs still resolve.
- `visits_count` is a counter cache maintained by `Visit`. Do not increment it by
  hand.
- Statistics are owner-only for owned URLs; for anonymous URLs the unguessable
  slug is the only credential.
