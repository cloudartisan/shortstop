module Base62
  CHARS = "0123456789ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz".freeze
  BASE = CHARS.length

  def self.encode(number)
    return CHARS[0] if number.zero? || number.nil?
    
    result = ""
    
    while number > 0
      remainder = number % BASE
      number /= BASE
      result = CHARS[remainder] + result
    end
    
    result
  end

  def self.decode(string)
    return 0 if string.blank?
    
    result = 0
    string.reverse.each_char.with_index do |char, index|
      power = BASE**index
      value = CHARS.index(char)
      result += value * power if value
    end
    
    result
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