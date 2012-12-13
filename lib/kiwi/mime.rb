class Kiwi::Mime

  attr_accessor :subtype, :media_type, :params

  def initialize str
    parts = str.split(/\s*;\s*/)
    @media_type, @subtype = parts.shift.split("/")

    @params = {}

    parts.each do |part|
      k,v = part.split(/\s*=\s*/)
      @params[k] = v
    end
  end


  def q
    (@params['q'] && @params['q'].to_f) || 1
  end


  def <=> other
    other.q <=> self.q
  end


  def includes? other
    return true if self.to_s == "*/*"

    other = self.class.new(other) if String === other

    self.media_type == other.media_type &&
      (self.subtype == "*" || self.subtype == other.subtype)
  end


  def to_s
    str = "#{@media_type}/#{@subtype}"
    params.each{|k,v| str << ";#{k}=#{v}" }
    str
  end
end
