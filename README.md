# Shortstop URL Shortener

A modern URL shortening service built with Ruby on Rails 7.1 and Bootstrap 5. This project is a complete rewrite of an older Rails 3.0 application, updated to use modern Rails features and best practices.

## Features

- Shorten long URLs to easy-to-share links
- Track the number of visits for each shortened URL
- QR codes for easy mobile sharing
- Copy to clipboard functionality
- Clean, responsive design using Bootstrap 5

## Technical Details

- Rails 7.1.3
- Ruby 3.4.2
- PostgreSQL database
- Base62 encoding for URL shortening
- Bootstrap 5 for frontend styling

## Requirements

- Ruby 3.4.2 (managed with rbenv)
- PostgreSQL server
- Bundler gem

## Installation

### Using Make (Recommended)

The project includes a Makefile with common commands to simplify development:

1. Clone the repository:
```bash
git clone https://github.com/your-username/shortstop.git
cd shortstop
```

2. Run the complete setup (sets up Ruby, installs dependencies, and initializes the database):
```bash
make setup
```

3. Start the server:
```bash
make server
```

4. Visit http://localhost:3000 in your web browser

### Available Make Commands

Run `make help` to see all available commands:

- `make setup` - Complete first-time application setup
- `make install` - Install dependencies via bundler
- `make ruby-setup` - Set up Ruby with rbenv
- `make db-setup` - Create and migrate the database
- `make db-reset` - Drop, recreate, and migrate the database
- `make db-migrate` - Run pending migrations
- `make server` - Start the development server
- `make console` - Open a Rails console
- `make routes` - Show Rails routes
- `make test` - Run tests
- `make lint` - Run code linting

### Manual Installation

If you prefer not to use Make, follow these steps manually:

#### Setting up Ruby with rbenv

1. Install rbenv if you haven't already:
```bash
# On macOS with Homebrew
brew install rbenv ruby-build

# Add rbenv to bash
echo 'eval "$(rbenv init -)"' >> ~/.bash_profile
source ~/.bash_profile

# For zsh users
echo 'eval "$(rbenv init -)"' >> ~/.zshrc
source ~/.zshrc
```

2. Install Ruby 3.4.2:
```bash
rbenv install 3.4.2
```

3. Set Ruby 3.4.2 as the project's Ruby version:
```bash
rbenv local 3.4.2
ruby -v  # Verify you're using 3.4.2
```

#### Setting up PostgreSQL

1. Install PostgreSQL:
```bash
# On macOS with Homebrew
brew install postgresql@15

# Start PostgreSQL service
brew services start postgresql@15
```

2. Make sure PostgreSQL command line tools are in your PATH:
```bash
# For Intel Macs:
export PATH="/usr/local/opt/postgresql@15/bin:$PATH"

# For Apple Silicon Macs:
export PATH="/opt/homebrew/opt/postgresql@15/bin:$PATH"

# Add to your ~/.zshrc or ~/.bash_profile to make it permanent
```

3. Create a PostgreSQL user:
```bash
# Create user with password (must provide a non-empty password when prompted)
createuser -d -P shortstop

# Or create user without password authentication (simpler for development)
createuser -d shortstop
```

#### Setting up the Application

1. Clone the repository:
```bash
git clone https://github.com/your-username/shortstop.git
cd shortstop
```

2. Install dependencies:
```bash
gem install bundler  # Install bundler if you don't have it
bundle install
```

3. Configure the database connection:
   - Edit `config/database.yml` if needed to match your PostgreSQL setup
   - If you created a custom user, update the username and password

4. Set up the database:
```bash
bundle exec rails db:create db:migrate
```

5. Start the Rails server:
```bash
bundle exec rails server
```

6. Visit http://localhost:3000 in your web browser

### Troubleshooting

#### Database Issues

- If PostgreSQL connection fails, ensure the PostgreSQL service is running:
```bash
brew services start postgresql@15
```

- Make sure your PostgreSQL path is correctly set:
```bash
# Add to your shell profile if needed
export PATH="/usr/local/opt/postgresql@15/bin:$PATH"
```

- For PostgreSQL authentication issues, check your `config/database.yml` configuration

#### Rails Application Issues

- If you encounter any issues with the URL shortening functionality, restart the Rails server after making changes:
```bash
# Stop the server with Ctrl+C, then restart
bundle exec rails server
```

- If changes to files in the `lib` directory don't seem to take effect, you may need to restart the Rails server
```bash
# Stop the server with Ctrl+C, then restart
bundle exec rails server
```

- For any other issues, check the Rails logs in `log/development.log`

## How It Works

Shortstop uses Base62 encoding (0-9, a-z, A-Z) to create short, unique URL slugs. When a user submits a long URL:

1. The URL is validated and saved to the database
2. The ID of the new record is encoded using Base62
3. This encoded value becomes the shortened URL path
4. When a user visits the shortened URL, they are redirected to the original URL
5. Each visit increments a counter to track usage

## Development

With Make:
```bash
# Run tests
make test

# Start the Rails console
make console

# Show all routes
make routes

# Run linting
make lint
```

Without Make:
```bash
# Run tests
bundle exec rspec

# Start the Rails console
bundle exec rails console

# Show all routes
bundle exec rails routes
```

## License

This project is open source and available under the [MIT License](LICENSE).
