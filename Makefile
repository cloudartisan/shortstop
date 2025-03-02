# Shortstop URL Shortener Makefile
# This Makefile provides common commands for setup and daily development

# Variables
RUBY_VERSION := 3.4.2
APP_NAME := shortstop
DB_NAME := shortstop_development
RAILS_PORT := 3000

# Colors for pretty output
BLUE := \033[0;34m
GREEN := \033[0;32m
YELLOW := \033[0;33m
RED := \033[0;31m
NC := \033[0m # No Color

.PHONY: help setup install ruby-setup db-setup db-reset db-migrate server console routes test lint

# Default target
help:
	@echo "${BLUE}Shortstop URL Shortener${NC} - Development Commands"
	@echo ""
	@echo "Available commands:"
	@echo "  ${GREEN}make setup${NC}       - Complete first-time application setup"
	@echo "  ${GREEN}make install${NC}     - Install dependencies via bundler"
	@echo "  ${GREEN}make ruby-setup${NC}  - Set up Ruby $(RUBY_VERSION) with rbenv"
	@echo "  ${GREEN}make db-setup${NC}    - Create and migrate the database"
	@echo "  ${GREEN}make db-reset${NC}    - Drop, recreate, and migrate the database"
	@echo "  ${GREEN}make db-migrate${NC}  - Run pending migrations"
	@echo "  ${GREEN}make server${NC}      - Start the development server"
	@echo "  ${GREEN}make console${NC}     - Open a Rails console"
	@echo "  ${GREEN}make routes${NC}      - Show Rails routes"
	@echo "  ${GREEN}make test${NC}        - Run tests"
	@echo "  ${GREEN}make lint${NC}        - Run code linting"
	@echo ""
	@echo "For more details, see README.md"

# Complete setup in one command
setup: ruby-setup install db-setup
	@echo "${GREEN}Setup complete!${NC} Run ${YELLOW}make server${NC} to start the application."

# Install dependencies
install:
	@echo "${BLUE}Installing dependencies...${NC}"
	@if ! command -v bundle > /dev/null; then \
		echo "${YELLOW}Installing bundler...${NC}"; \
		gem install bundler; \
	fi
	bundle install

# Ruby setup with rbenv
ruby-setup:
	@echo "${BLUE}Setting up Ruby $(RUBY_VERSION)...${NC}"
	@if ! command -v rbenv > /dev/null; then \
		echo "${RED}rbenv not found!${NC} Please install rbenv first:"; \
		echo "  On macOS: ${YELLOW}brew install rbenv ruby-build${NC}"; \
		echo "  Then add to your shell profile and restart your terminal."; \
		exit 1; \
	fi
	@if ! rbenv versions | grep -q "$(RUBY_VERSION)"; then \
		echo "${YELLOW}Installing Ruby $(RUBY_VERSION)...${NC}"; \
		rbenv install $(RUBY_VERSION); \
	fi
	rbenv local $(RUBY_VERSION)
	@echo "${GREEN}Ruby $(RUBY_VERSION) is set up.${NC}"

# Database setup
db-setup:
	@echo "${BLUE}Setting up database...${NC}"
	@# Skip PostgreSQL check and assume Rails will handle database connection
	bundle exec rails db:create db:migrate db:seed
	@echo "${GREEN}Database setup complete with test user created.${NC}"

# Database reset (drop, create, migrate)
db-reset:
	@echo "${BLUE}Resetting database...${NC}"
	bundle exec rails db:drop db:create db:migrate db:seed
	@echo "${GREEN}Database reset complete with test user created.${NC}"

# Run migrations
db-migrate:
	@echo "${BLUE}Running migrations...${NC}"
	bundle exec rails db:migrate
	@echo "${GREEN}Migrations complete.${NC}"

# Start the server
server:
	@echo "${BLUE}Starting server on http://localhost:$(RAILS_PORT)...${NC}"
	bundle exec rails server -p $(RAILS_PORT)

# Open a Rails console
console:
	@echo "${BLUE}Opening Rails console...${NC}"
	bundle exec rails console

# Show routes
routes:
	@echo "${BLUE}Available routes:${NC}"
	bundle exec rails routes

# Run tests
test:
	@echo "${BLUE}Running tests...${NC}"
	bundle exec rspec

# Run linting
lint:
	@echo "${BLUE}Running Rubocop linting...${NC}"
	@if ! bundle list | grep -q "rubocop"; then \
		echo "${YELLOW}Rubocop not found in Gemfile. Adding it temporarily...${NC}"; \
		bundle add --group development rubocop; \
	fi
	bundle exec rubocop