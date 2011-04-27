class Url < ActiveRecord::Base
  validates :url, :presence => true
  validates_url_format_of :url,
                          :allow_nil => true,
                          :message => 'is completely unacceptable'
end
