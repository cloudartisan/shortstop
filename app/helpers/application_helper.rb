module ApplicationHelper
  # Google sign-in is only offered when it is actually configured. Without
  # credentials the button used to redirect to Google with an empty client_id,
  # which lands the user on a Google error page.
  def google_oauth_configured?
    ENV["GOOGLE_CLIENT_ID"].present? && ENV["GOOGLE_CLIENT_SECRET"].present?
  end
end
