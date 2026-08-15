# Shortstop URL Shortener Guide

## Commands
- Start server: `rails server` or `rails s`
- Console: `rails console` or `rails c`
- Run all tests: `bundle exec rspec`
- Run specific test: `bundle exec rspec spec/models/url_spec.rb`
- Database setup: `rails db:create db:migrate`
- Reset database: `rails db:drop db:create db:migrate`
- Create new migration: `rails g migration MigrationName`

## Authentication Setup
- OAuth configuration: Set these environment variables
  - GOOGLE_CLIENT_ID=[your_google_client_id]
  - GOOGLE_CLIENT_SECRET=[your_google_client_secret]
- Create these credentials at https://console.developers.google.com/

## Test User Account
For local testing, a test user is created with the following credentials:
- Email: admin@example.com
- Password: password123
- This user has sample URLs with visit data (run `rails db:seed` to create)

## Code Style
- Indentation: 2 spaces
- Modern Ruby hash syntax: `key: value`
- Models: Use validators and callbacks appropriately
- Controllers: Keep thin, use before_action filters
- Routes: RESTful with meaningful names
- Views: Use partials for reusable components
- URL validation: Use the validate_url gem
- Base62 encoding: For URL shortening (lib/base62.rb)
- Error handling: Use proper status codes and flash messages

## Project Architecture
A modern Rails 7.1 URL shortener app using:
- PostgreSQL database
- Bootstrap 5 for frontend styling
- FriendlyID for SEO-friendly URLs
- Pagy for pagination
- RESTful controllers with specific actions
- Devise for authentication
- OmniAuth for social logins