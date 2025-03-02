FactoryBot.define do
  factory :url do
    original_url { "https://example.com/some/very/long/path/to/a/resource?with=parameters&and=more" }
    shortened_path { nil } # Will be auto-generated
    visits_count { 0 }
    
    # This will call set_shortened_path after create
    after(:create) do |url|
      url.set_shortened_path
    end
    
    # Factory for a URL that has been visited multiple times
    trait :with_visits do
      visits_count { 42 }
    end
  end
end
