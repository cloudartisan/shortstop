# This file should ensure the existence of records required to run the application in every environment (production,
# development, test). The code here should be idempotent so that it can be executed at any point in every environment.
# The data can then be loaded with the bin/rails db:seed command (or created alongside the database with db:setup).

# Development/test convenience user. The password comes from the environment so
# that a real credential is never committed; SEED_ADMIN_PASSWORD is set in
# .env.example for local use.
if Rails.env.development? || Rails.env.test?
  email = ENV.fetch("SEED_ADMIN_EMAIL", "admin@example.com")
  password = ENV.fetch("SEED_ADMIN_PASSWORD", "password123")

  admin = User.find_or_initialize_by(email: email)
  admin.name = "Admin User"
  admin.password = password
  admin.password_confirmation = password
  admin.save!

  puts "Created test user:"
  puts "  Email: #{email}"
  puts "  Password: #{password == 'password123' ? 'password123 (default - override with SEED_ADMIN_PASSWORD)' : '[from SEED_ADMIN_PASSWORD]'}"

  # Create test URLs for the admin user
  if admin.urls.empty?
    test_urls = [
      { original_url: "https://www.google.com",    shortened_path: "google" },
      { original_url: "https://www.github.com",    shortened_path: "github" },
      { original_url: "https://www.wikipedia.org", shortened_path: "wiki" }
    ]

    user_agents = [
      "Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/91.0.4472.124 Safari/537.36",
      "Mozilla/5.0 (Macintosh; Intel Mac OS X 10_15_7) AppleWebKit/605.1.15 (KHTML, like Gecko) Version/14.1.1 Safari/605.1.15",
      "Mozilla/5.0 (X11; Linux x86_64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/92.0.4515.107 Safari/537.36"
    ]

    test_urls.each do |url_data|
      url = admin.urls.create!(
        original_url: url_data[:original_url],
        shortened_path: url_data[:shortened_path]
      )

      rand(5..15).times do
        Visit.create!(
          url: url,
          referer: [ "https://www.google.com", "https://www.github.com", nil ].sample,
          user_agent: user_agents.sample,
          created_at: rand(1..30).days.ago
        )
      end
    end

    # visits_count is a counter cache now, so it is already correct - but the
    # backdated created_at values above bypass the callback ordering, so make sure.
    admin.urls.each { |url| Url.reset_counters(url.id, :visits) }

    puts "Created #{test_urls.length} test URLs with visits data"
  end
end
