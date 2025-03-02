class Url < ApplicationRecord
  has_many :visits, dependent: :destroy
  
  validates :original_url, presence: true, uniqueness: true
  validates :original_url, url: { allow_blank: true }
  validates :shortened_path, uniqueness: true, allow_blank: true
  
  before_create :generate_shortened_path
  
  # Generate random URL slug based on ID
  def generate_shortened_path
    return if self.shortened_path.present?
    
    # We'll set this after save since we need the ID
    self.shortened_path = nil
  end
  
  # Called after create to generate the shortened path
  def set_shortened_path
    update_column(:shortened_path, id.to_base62)
  end
  
  # Increment the visits counter
  def increment_visits!
    increment!(:visits_count)
  end
  
  # Full shortened URL including host
  def short_url(host = nil)
    return nil unless shortened_path.present? && host.present?
    "#{host}/#{shortened_path}"
  end
  
  # Find a URL by its shortened path
  def self.find_by_shortened_path(path)
    find_by(shortened_path: path)
  end
end
