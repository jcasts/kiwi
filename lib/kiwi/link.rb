class Kiwi::Link

  attr_reader :params, :path, :rsc_method

  def initialize rsc_method, path, params=[]
    @rsc_method = rsc_method.to_s.downcase
    @path       = path
    @params     = params
  end


  ##
  # Builds the full link url and resource method

  def build params=nil
    pvalues = {}
    path    = @path.dup

    @params.each do |param|
      val = param.value_from params

      new_path = path.gsub %r{#{Kiwi::Route.delimiter}:#{param.name}([^\w]|$)},
                  (Kiwi::Route.delimiter + val.to_s + '\1')

      path = new_path and next if path != new_path

      pvalues[param.name] = val unless val.nil? && param.optional
    end if params

    query = "?#{build_query(pvalues)}" unless pvalues.empty?

    {:href => "#{path}#{query}", :method => @rsc_method}
  end


  ##
  # Hash representation of this link.

  def to_hash
    {
      :href   => @path,
      :method => @rsc_method,
      :params => @params.map(&:to_hash)
    }
  end


  private


  ##
  # Builds a nested URI query.

  def build_query data, param=nil
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
