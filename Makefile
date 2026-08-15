# Shortstop URL Shortener Makefile
# Common commands for setup and daily development.

RUBY_VERSION := 3.4.10
APP_NAME := shortstop
RAILS_PORT := 3000

BLUE := \033[0;34m
GREEN := \033[0;32m
YELLOW := \033[0;33m
RED := \033[0;31m
NC := \033[0m

.PHONY: help setup install ruby-setup db-setup db-reset db-migrate server console routes test lint security audit docker-up docker-down docker-logs docker-shell

help:
	@echo "${BLUE}Shortstop URL Shortener${NC} - Development Commands"
	@echo ""
	@echo "Running locally:"
	@echo "  ${GREEN}make setup${NC}       - Complete first-time application setup"
	@echo "  ${GREEN}make install${NC}     - Install dependencies via bundler"
	@echo "  ${GREEN}make ruby-setup${NC}  - Set up Ruby $(RUBY_VERSION) with rbenv"
	@echo "  ${GREEN}make db-setup${NC}    - Create, migrate and seed the database"
	@echo "  ${GREEN}make db-reset${NC}    - Drop, recreate, migrate and seed the database"
	@echo "  ${GREEN}make db-migrate${NC}  - Run pending migrations"
	@echo "  ${GREEN}make server${NC}      - Start the development server"
	@echo "  ${GREEN}make console${NC}     - Open a Rails console"
	@echo "  ${GREEN}make routes${NC}      - Show Rails routes"
	@echo ""
	@echo "Running in Docker (no local Ruby or PostgreSQL needed):"
	@echo "  ${GREEN}make docker-up${NC}    - Build and start the app on http://localhost:$(RAILS_PORT)"
	@echo "  ${GREEN}make docker-down${NC}  - Stop it and remove the volumes"
	@echo "  ${GREEN}make docker-logs${NC}  - Follow the application log"
	@echo "  ${GREEN}make docker-shell${NC} - Open a shell in the running container"
	@echo ""
	@echo "Checks:"
	@echo "  ${GREEN}make test${NC}        - Run the RSpec suite"
	@echo "  ${GREEN}make lint${NC}        - Run RuboCop"
	@echo "  ${GREEN}make security${NC}    - Run Brakeman"
	@echo "  ${GREEN}make audit${NC}       - Check dependencies for known CVEs"
	@echo ""
	@echo "For more details, see README.md"

setup: ruby-setup install db-setup
	@echo "${GREEN}Setup complete!${NC} Run ${YELLOW}make server${NC} to start the application."

install:
	@echo "${BLUE}Installing dependencies...${NC}"
	@if ! command -v bundle > /dev/null; then \
		echo "${YELLOW}Installing bundler...${NC}"; \
		gem install bundler; \
	fi
	bundle install

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

db-setup:
	@echo "${BLUE}Setting up database...${NC}"
	bundle exec rails db:create db:migrate db:seed
	@echo "${GREEN}Database setup complete with test user created.${NC}"

db-reset:
	@echo "${BLUE}Resetting database...${NC}"
	bundle exec rails db:drop db:create db:migrate db:seed
	@echo "${GREEN}Database reset complete with test user created.${NC}"

db-migrate:
	@echo "${BLUE}Running migrations...${NC}"
	bundle exec rails db:migrate
	@echo "${GREEN}Migrations complete.${NC}"

server:
	@echo "${BLUE}Starting server on http://localhost:$(RAILS_PORT)...${NC}"
	bundle exec rails server -p $(RAILS_PORT)

console:
	@echo "${BLUE}Opening a Rails console...${NC}"
	bundle exec rails console

routes:
	@echo "${BLUE}Available routes:${NC}"
	bundle exec rails routes

test:
	@echo "${BLUE}Running tests...${NC}"
	bundle exec rspec

lint:
	@echo "${BLUE}Running RuboCop...${NC}"
	bundle exec rubocop

security:
	@echo "${BLUE}Running Brakeman...${NC}"
	bundle exec brakeman --no-pager

audit:
	@echo "${BLUE}Checking dependencies for known CVEs...${NC}"
	bundle exec bundler-audit check --update

docker-up:
	@echo "${BLUE}Starting Docker stack on http://localhost:$(RAILS_PORT)...${NC}"
	docker compose up -d --build
	@echo "${GREEN}Running.${NC} Follow the log with ${YELLOW}make docker-logs${NC}."

docker-down:
	docker compose down -v

docker-logs:
	docker compose logs -f web

docker-shell:
	docker compose exec web bash
