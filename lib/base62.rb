SIXTYTWO = ('0'..'9').to_a + ('a'..'z').to_a + ('A'..'Z').to_a

def to_s_62(i)
  return '0' if i == 0
  s = ''
  while i > 0
    s << SIXTYTWO[i.modulo(62)]
    i /= 62
  end
  s.reverse
end
