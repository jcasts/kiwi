class Kiwi::Route

  ##
  # The route delimiter. Defaults to Kiwi.route_delim, or "/".

  def self.delimiter new_del=nil
    @delimiter   = new_del if new_del
    @delimiter ||= Kiwi.route_delim || "/"
  end


  ##
  # Turns string path into a Regexp matcher and key names. (Thanks Sinatra!)

  def self.parse_path path_str
    return [path_str, []] if Regexp === path_str

    keys          = []
    special_chars = %w{. + ( )}
    delim         = Regexp.escape self.delimiter

    pattern =
      path_str.to_str.gsub(/((:\w+)|[\*#{special_chars.join}])/) do |match|
        case match
        when "*"
          keys << 'splat'
          "(.*?)"
        when *special_chars
          Regexp.escape(match)
        else
          keys << $2[1..-1]
          "([^#{delim}?#]+)"
        end
      end

    [/^#{pattern}$/, keys]
  end


  attr_reader :path, :matcher, :keys


  ##
  # Create a new Route object. Parts will be joined with the route delimiter.

  def initialize *parts
    string = parts.join Kiwi.route_delim
    delim  = Regexp.escape self.class.delimiter
    @path  = string.sub(/^(#{delim})?/, self.class.delimiter).
                    sub(/(\w)(#{delim})?$/, '\1')

    @matcher, @keys = self.class.parse_path @path
  end


  ##
  # Returns true if the given path matches this route.

  def routes? path_str
    path_str =~ @matcher
  end


  ##
  # Parses the given path and extracts any embedded path params.
  # Returns a hash of params if the path is parseable, otherwise returns nil.

  def parse path_str
    match  = @matcher.match path_str
    values = match.captures.to_a

    if @keys.any?
      @keys.zip(values).inject({}) do |hash,(k,v)|
        if k == 'splat'
          (hash[k] ||= []) << v
        else
          hash[k] = v
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
