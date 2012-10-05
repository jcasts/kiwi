class Kiwi::Link

  PATH_PARAM_MATCHER = %r{(\?)?:(\w+)([^\w]|$)}

  attr_reader :params, :path, :rsc_method, :rel
  attr_accessor :label

  def initialize rsc_method, path, rel, params=[]
    @rsc_method = rsc_method.to_s.downcase
    @path       = path
    @params     = params
    @rel        = rel.to_s
    @label      = nil
  end


  ##
  # Builds the full link url and resource method

  def build params=nil
    hash = {:href => build_path(params), :method => @rsc_method, :rel => @rel}
    hash[:label] = @label if @label

    hash
  end


  ##
  # Hash representation of this link.

  def to_hash
    req_params = {}
    @params.each do |param|
      req_params[param.name] = ":#{param.name}" unless param.optional
    end

    hash = {
      :href   => build_path(req_params),
      :method => @rsc_method,
      :rel    => @rel,
      :params => @params.map(&:to_hash)
    }

    hash[:label] = @label if @label

    hash
  end


  ##
  # Build and return the path of the link with given params.

  def build_path params=nil
    pvalues  = {}
    path     = @path.dup
    params ||= {}

    @params.each do |param|
      val = param.value_from params
      pvalues[param.name] = val unless val.nil? && param.optional
    end

    path.gsub!(PATH_PARAM_MATCHER) do |match|
      key = $2.to_sym
      val = pvalues[key]

      if val
        pvalues.delete(key)
        "#{val}#{$3}"

      elsif $1
        ""

      else
        "#{key.inspect}#{$3}"
      end
    end

    query = self.class.build_query(pvalues) unless pvalues.empty?
    path << (path.include?("?") ? "&#{query}" : "?#{query}") if query

    path.gsub!(%r{([^/])/+(/|$)}, '\1\2')
    path
  end


  ##
  # Builds a nested URI query.

  def self.build_query data, param=nil
    return data.to_s unless param || Hash === data

    case data
    when Array
      out = data.map do |value|
        key = "#{param}[]"
        build_query value, key
      end

      out.join "&"

    when Hash
      out = data.map do |key, value|
        key = param.nil? ? key : "#{param}[#{key}]"
        build_query value, key
      end

      out.join "&"

    else
      "#{param}=#{data}"
    end
  end
end
