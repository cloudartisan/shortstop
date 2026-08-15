FactoryBot.define do
  factory :visit do
    url
    ip_address { "203.0.113.42" }
    user_agent { "Mozilla/5.0 (Macintosh; Intel Mac OS X 10_15_7) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/120.0.0.0 Safari/537.36" }
    referer { "https://news.ycombinator.com/item?id=1" }

    trait :direct do
      referer { nil }
    end

    trait :hostless_referer do
      referer { "mailto:someone@example.com" }
    end
  end
end
