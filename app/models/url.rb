# Use the model's ID (PK/Serial) to generate a token which can be reversed:
#
#   Url.find(7213).shortened        #=> 5kd
#   Url.find_by_shortened("5kd")    #=> #<Url id: 7213...>
#
# Based on this gist:
#
#   https://gist.github.com/581399#file_active_record_url_shortening.rb
class Url < ActiveRecord::Base
  Radix = 36

  validates :url, :presence => true
  validates_url_format_of :url,
                          :allow_nil => true,
                          :message => 'is completely unacceptable'

  # Convert URL ID to a shortened version
  def shortened
    id.to_s(Radix)
  end

  # Unconvert the shortened version back to the URL's ID
  def self.shortened_to_id(shortened)
    shortened.to_i(Radix)
  end

  # Unconvert shortened back to the URL's ID and lookup 
  def self.find_by_shortened(shortened)
    find shortened_to_id(shortened)
  end

end
