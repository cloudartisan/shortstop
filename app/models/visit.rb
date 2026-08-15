class Visit < ApplicationRecord
  # counter_cache keeps urls.visits_count in step with this table automatically.
  # It used to be incremented by hand in the controller, which drifted whenever
  # a Visit failed to save or was destroyed.
  belongs_to :url, counter_cache: :visits_count

  # Record a visit with request information. Analytics must never break a
  # redirect, so failures are logged rather than raised.
  def self.record(url, request)
    create!(
      url: url,
      ip_address: request.remote_ip,
      user_agent: request.user_agent,
      referer: request.referer
    )
  rescue ActiveRecord::ActiveRecordError => e
    Rails.logger.error("Failed to record visit for url #{url.id}: #{e.message}")
    nil
  end
end
