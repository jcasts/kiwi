class Kiwi::Link

  attr_reader :params, :path, :http_method

  def initialize http_method, path, params=[]
    @http_method = http_method.to_sym
    @path        = path
    @params      = params
  end


  ##
  # Builds the full link url and http method

  def build params={}
    pvalues = {}
    path    = @path.dup

    @params.each do |param|
      val = param.value_from params

      new_path = path.gsub %r{#{Kiwi::Route.delimiter}:#{param.name}([^\w]|$)},
                  (Kiwi::Route.delimiter + val.to_s + '\1')

      path = new_path and next if path != new_path

      pvalues[param.name] = val unless val.nil? && param.optional
    end

    query = "?#{build_query(pvalues)}" unless pvalues.empty?

    {:href => "#{path}#{query}", :method => @http_method}
  end


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


  ##
  # Hash representation of this link.

  def to_hash
    {
      :href   => @path,
      :method => @http_method,
      :params => @params.map(&:to_hash)
    }
  end
end
