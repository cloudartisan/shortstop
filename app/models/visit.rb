class Visit < ApplicationRecord
  belongs_to :url

  validates :url, presence: true

  # Record a visit with request information
  def self.record(url, request)
    create(
      url: url,
      ip_address: request.remote_ip,
      user_agent: request.user_agent,
      referer: request.referer
    )
  end
end