# OmniAuth test mode, so the Google callback can be exercised without hitting
# Google. Individual specs override the mock via `stub_google_oauth`.
OmniAuth.config.test_mode = true
OmniAuth.config.logger = Rails.logger
# Route failures through Devise's failure app instead of raising, so the
# failure path is testable the way a real one behaves.
OmniAuth.config.failure_raise_out_environments = []

module OmniAuthHelpers
  def stub_google_oauth(email: "oauth-user@example.com", name: "OAuth User", uid: "google-123")
    OmniAuth.config.mock_auth[:google_oauth2] = OmniAuth::AuthHash.new(
      provider: "google_oauth2",
      uid: uid,
      info: { email: email, name: name }
    )
    Rails.application.env_config["omniauth.auth"] = OmniAuth.config.mock_auth[:google_oauth2]
  end

  def stub_google_oauth_failure(reason = :invalid_credentials)
    OmniAuth.config.mock_auth[:google_oauth2] = reason
  end
end

RSpec.configure do |config|
  config.include OmniAuthHelpers

  config.after do
    OmniAuth.config.mock_auth[:google_oauth2] = nil
    Rails.application.env_config.delete("omniauth.auth")
  end
end
