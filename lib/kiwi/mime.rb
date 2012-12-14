class Kiwi::Mime

  attr_accessor :subtype, :media_type, :format, :params

  def initialize str, strict=false
    parts = str.split(/\s*;\s*/)
    @media_type, @subtype = parts.shift.split("/")
    @media_type, @subtype = "*", @media_type if @subtype.nil?

    raise ArgumentError,
      "Non strict mime-type: `#{display}'. Specify `media-type/subtype'." if
      strict && !strict?

    @format = @subtype.split("+").last

    @params = {}

    parts.each do |part|
      k,v = part.split(/\s*=\s*/)
      @params[k] = v
    end
  end


  def q
    (@params['q'] && @params['q'].to_f) || 1
  end


  def strict?
    @media_type != "*" && @subtype != "*"
  end


  def display
    "#{@media_type}/#{@subtype}"
  end


  def === other
    super || self.class === other && self.display == other.display
  end


  def == other
    self.to_s == other.to_s
  end


  def <=> other
    other.q <=> self.q
  end


  def matches? other
    return true if self.to_s == "*/*"

    other = self.class.new(other) if String === other

    (@media_type == "*" || other.media_type == "*" ||
      @media_type == other.media_type) &&
      (@subtype == "*" || other.subtype == "*" ||
        @subtype == other.subtype)
  end


  def to_s
    str = self.display
    params.each{|k,v| str << ";#{k}=#{v}" }
    str
  end
end
