class Url < ApplicationRecord
  # Length of newly generated slugs. 62**7 keeps collisions negligible while
  # staying short enough to share.
  SLUG_LENGTH = 7

  # Slugs that would shadow a real route in config/routes.rb. Historical
  # id-derived slugs could collide with these (id 3523 encodes to "up").
  RESERVED_SLUGS = %w[up new edit urls users dashboard assets rails robots favicon].freeze

  belongs_to :user, optional: true
  has_many :visits, dependent: :destroy

  validates :original_url, presence: true
  validates :original_url, url: { allow_blank: true }
  validates :shortened_path, uniqueness: true, allow_blank: true
  validates :shortened_path, exclusion: { in: RESERVED_SLUGS, message: "is reserved" }, allow_blank: true

  # Scope for finding duplicate URLs for the same user
  scope :for_user_and_url, ->(user_id, original_url) {
    where(user_id: user_id, original_url: original_url)
  }

  # Rows created before slug generation moved into the model can have a NULL
  # path; they are unreachable and must never be rendered as links.
  scope :resolvable, -> { where.not(shortened_path: nil) }

  before_validation :generate_shortened_path, on: :create

  # Full shortened URL including host
  def short_url(host = nil)
    return nil unless shortened_path.present? && host.present?
    "#{host}/#{shortened_path}"
  end

  # Find a URL by its shortened path
  def self.find_by_shortened_path(path)
    find_by(shortened_path: path)
  end

  private

  # Assigns a random, unguessable slug. Runs before validation so the record is
  # never inserted without one, and retries on the (vanishingly rare) collision.
  def generate_shortened_path
    return if shortened_path.present?

    10.times do
      candidate = Base62.random(SLUG_LENGTH)
      next if RESERVED_SLUGS.include?(candidate)
      next if self.class.exists?(shortened_path: candidate)

      self.shortened_path = candidate
      return
    end

    raise "Unable to generate a unique shortened path after 10 attempts"
  end
end
