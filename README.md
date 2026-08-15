# Shortstop URL Shortener

A URL shortening service built with Ruby on Rails 8 and Bootstrap 5. This project is a rewrite of an older Rails 3.0 application.

## Features

- Shorten long URLs to easy-to-share links, with or without an account
- Optional accounts, by email or Google sign-in, so your links follow you between devices
- Personal dashboard listing the URLs you have created
- Per-link statistics: visits over time, browser breakdown and top referrers
- QR codes for easy mobile sharing
- Copy to clipboard
- Responsive design using Bootstrap 5

Signing in is optional. Anonymous links work exactly the same way; they are just
remembered in your browser session rather than tied to an account.

## Technical Details

- Rails 8.1
- Ruby 3.4.10
- PostgreSQL
- Hotwire (Turbo and Stimulus) over importmap-rails, no JavaScript build step
- Random Base62 slugs, so short links cannot be enumerated
- Devise for authentication, OmniAuth for Google sign-in

## Running it

### With Docker (recommended)

The only prerequisite is Docker.

```bash
git clone https://github.com/cloudartisan/shortstop.git
cd shortstop
make docker-up
```

That builds the image, starts PostgreSQL, creates and migrates the database and
serves the app on http://localhost:3000. Your working tree is mounted into the
container, so edits are picked up without a rebuild.

```bash
make docker-logs    # follow the application log
make docker-shell   # a shell inside the container
make docker-down    # stop everything and remove the volumes
```

To seed the sample account and links, run `docker compose exec web ./bin/rails db:seed`.

### Locally

Prerequisites:

- Ruby 3.4.10 (managed with rbenv)
- PostgreSQL
- Bundler

No Node.js and no JavaScript build step: the front end is served through
importmap-rails.

```bash
git clone https://github.com/cloudartisan/shortstop.git
cd shortstop
make setup     # installs Ruby via rbenv, bundles, creates and seeds the database
make server
```

Then visit http://localhost:3000.

`config/database.yml` reads `POSTGRES_HOST`, `POSTGRES_PORT`, `POSTGRES_USER`,
`POSTGRES_PASSWORD` and `POSTGRES_DB` from the environment, defaulting to a
local socket-less connection on `localhost:5432`. Set them in `.env` if your
setup differs, or set `DATABASE_URL` to override the lot.

### The seeded account

`rails db:seed` creates a development user with sample links and visit data:

- Email: `admin@example.com`
- Password: `password123`

Both are overridable with `SEED_ADMIN_EMAIL` and `SEED_ADMIN_PASSWORD`, and the
seeds only run in development and test.

## Google sign-in (optional)

The Google button only appears once credentials are configured.

1. Create a project at https://console.cloud.google.com/
2. Create OAuth credentials of type "Web application"
3. Add the authorised redirect URI `http://localhost:3000/users/auth/google_oauth2/callback`
4. Copy `.env.example` to `.env` and fill in:

   ```
   GOOGLE_CLIENT_ID=your_client_id
   GOOGLE_CLIENT_SECRET=your_client_secret
   ```

## Make targets

Run `make help` for the full list.

| Target | What it does |
| --- | --- |
| `make setup` | First-time local setup: Ruby, gems, database, seeds |
| `make server` | Start the development server |
| `make console` | Open a Rails console |
| `make routes` | Show the routing table |
| `make db-setup` / `db-reset` / `db-migrate` | Database tasks (setup and reset also seed) |
| `make docker-up` / `docker-down` / `docker-logs` / `docker-shell` | Docker stack |
| `make test` | Run the RSpec suite |
| `make lint` | Run RuboCop |
| `make security` | Run Brakeman |
| `make audit` | Check dependencies for known CVEs |

## How It Works

Shortstop generates a random 7-character Base62 slug (0-9, a-z, A-Z) for each
new link, checked for uniqueness and against a list of reserved words that would
otherwise shadow real routes. When someone visits a short link they are
redirected to the original URL and the visit is recorded, which updates the
link's counter cache and feeds the statistics page.

Slugs used to be the record's ID in Base62, which meant every link on the
service could be found by counting upwards. Links created before that change
keep working; new ones are random.

## Development

```bash
bundle exec rspec        # tests
bundle exec rubocop      # linting
bundle exec brakeman     # static security analysis
bundle exec bundler-audit check --update   # dependency CVEs
```

CI runs all four on every push and pull request. See `.github/workflows/ci.yml`.

## Troubleshooting

**PostgreSQL connection failures.** Check the service is running and that the
`POSTGRES_*` environment variables match your setup. With Docker this is handled
for you.

**Changes to `lib/` not taking effect.** Restart the server; `lib` is eager
loaded at boot.

For anything else, check `log/development.log`.

## Licence

Released under the [MIT Licence](LICENSE).
