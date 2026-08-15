require "securerandom"

module Base62
  CHARS = "0123456789ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz".freeze
  BASE = CHARS.length

  # Raised when a string contains characters outside the Base62 alphabet.
  class InvalidCharacter < ArgumentError; end

  def self.encode(number)
    raise ArgumentError, "number must not be nil" if number.nil?
    raise ArgumentError, "number must not be negative" if number.negative?
    return CHARS[0] if number.zero?

    result = ""

    while number > 0
      remainder = number % BASE
      number /= BASE
      result = CHARS[remainder] + result
    end

    result
  end

  def self.decode(string)
    return 0 if string.nil? || string.empty?

    string.reverse.each_char.with_index.sum do |char, index|
      value = CHARS.index(char)
      raise InvalidCharacter, "#{char.inspect} is not a Base62 character" if value.nil?

      value * (BASE**index)
    end
  end

  # A cryptographically random slug. Used for newly created short links so that
  # they cannot be enumerated by counting, unlike the historical id-derived ones.
  def self.random(length)
    Array.new(length) { CHARS[SecureRandom.random_number(BASE)] }.join
  end
end

# Extend Integer class with to_base62 method
class Integer
  def to_base62
    Base62.encode(self)
  end
end

# Extend String class with from_base62 method
class String
  def from_base62
    Base62.decode(self)
  end
end
