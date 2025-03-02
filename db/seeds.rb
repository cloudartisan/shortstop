# This file should ensure the existence of records required to run the application in every environment (production,
# development, test). The code here should be idempotent so that it can be executed at any point in every environment.
# The data can then be loaded with the bin/rails db:seed command (or created alongside the database with db:setup).

# Create a test user for development
if Rails.env.development? || Rails.env.test?
  # Create admin user
  admin = User.find_or_initialize_by(email: 'admin@example.com')
  admin.name = 'Admin User'
  admin.password = 'password123'
  admin.password_confirmation = 'password123'
  admin.save!
  
  puts "Created test user:"
  puts "  Email: admin@example.com"
  puts "  Password: password123"
  
  # Create test URLs for the admin user
  if admin.urls.empty?
    test_urls = [
      { 
        original_url: 'https://www.google.com', 
        shortened_path: 'google' 
      },
      { 
        original_url: 'https://www.github.com', 
        shortened_path: 'github' 
      },
      { 
        original_url: 'https://www.wikipedia.org', 
        shortened_path: 'wiki' 
      }
    ]
    
    test_urls.each do |url_data|
      url = admin.urls.create!(
        original_url: url_data[:original_url],
        shortened_path: url_data[:shortened_path]
      )
      # Simulate some visits
      rand(5..15).times do
        Visit.create!(
          url: url,
          referer: ['https://www.google.com', 'https://www.github.com', nil].sample,
          user_agent: [
            'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/91.0.4472.124 Safari/537.36',
            'Mozilla/5.0 (Macintosh; Intel Mac OS X 10_15_7) AppleWebKit/605.1.15 (KHTML, like Gecko) Version/14.1.1 Safari/605.1.15',
            'Mozilla/5.0 (X11; Linux x86_64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/92.0.4515.107 Safari/537.36'
          ].sample,
          created_at: rand(1..30).days.ago
        )
      end
      
      # Update the visits count
      url.update(visits_count: url.visits.count)
    end
    
    puts "Created #{test_urls.length} test URLs with visits data"
  end
end
