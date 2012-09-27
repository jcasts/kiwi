class Kiwi::Route

  ##
  # The route delimiter. Defaults to Kiwi.route_delim, or "/".

  def self.delimiter new_del=nil
    @delimiter   = new_del if new_del
    @delimiter ||= Kiwi.route_delim || "/"
  end


  ##
  # Temporary resource id param name. Defaults to _kiwi_id.

  def self.tmp_id new_id=nil
    @tmp_id   = new_id if new_id
    @tmp_id ||= "_kiwi_id"
  end


  ##
  # Turns string path into a Regexp matcher and key names. (Thanks Sinatra!)

  def self.parse_path path_str, &block
    return [path_str, []] if Regexp === path_str

    keys          = []
    special_chars = %w{. + ( )}
    delim         = Regexp.escape self.delimiter

    pattern =
      path_str.to_str.gsub(/((:\w+)|[\*#{special_chars.join}])/) do |match|
        case match
        when "*"
          keys << 'splat'
          yield keys.last if block_given?
          "(.*?)"
        when *special_chars
          Regexp.escape(match)
        else
          keys << $2[1..-1]
          yield keys.last if block_given?
          "([^#{delim}?#]+)"
        end
      end

    [/^#{pattern}$/, keys]
  end


  attr_reader :path, :matcher, :id_matcher, :keys


  ##
  # Create a new Route object. Parts will be joined with the route delimiter.
  # If a block is given, will yield for every special key found.

  def initialize *parts, &block
    string = parts.join Kiwi.route_delim
    delim  = Regexp.escape self.class.delimiter
    @path  = string.sub(/^(#{delim})*/, self.class.delimiter).
                    sub(/([^#{delim}])(#{delim})?$/, '\1')

    @matcher, = self.class.parse_path @path, &block

    rpath = "#{@path}#{self.class.delimiter}?:#{self.class.tmp_id}?"
    @id_matcher, @keys = self.class.parse_path rpath, &block
  end


  ##
  # Returns true if the given path matches this route.

  def routes? path_str
    path_str =~ @matcher
  end


  ##
  # Returns true if the given path with appended id matches this route.

  def routes_with_id? path_str
    path_str =~ @id_matcher
  end


  ##
  # Parses the given path and extracts any embedded path params.
  # Returns a hash of params if the path is parseable, otherwise returns nil.

  def parse path_str
    match = @id_matcher.match path_str
    return unless match

    values = match.captures.to_a

    if @keys.any?
      @keys.zip(values).inject({}) do |hash,(k,v)|
        if k == 'splat'
          (hash[k] ||= []) << v
        else
          hash[k] = v unless v.nil?
        end

        hash
      end

    elsif values.any?
      {'captures' => values}

    else
      {}
    end
  end


  ##
  # The String representation of the route.

  def to_s
    @path
  end
end
