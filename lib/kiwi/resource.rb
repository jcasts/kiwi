
class Kiwi::Resource

  def self.inherited subclass
    new_route = subclass.name.split("::").last
    new_route.gsub!(/(.)([A-Z])/,'\1_\2').downcase!
    subclass.route new_route
  end


  ##
  # An optional description for the resource.

  def self.desc string=nil
    return @desc unless string
    @desc = string
  end


  ##
  # The param description and validator accessor.

  def self.param
    @params ||= Class.new Kiwi::Validator
  end


  ##
  # The route to access this resource. Defaults to the underscored version
  # of the class name.

  def self.route string=nil
    return @route unless string
    @route = parse_path string
  end


  ##
  # Parse a path into a matcher with key params.

  def self.parse_path path
    return [path, []] if Regexp === path

    path = path.sub(/^\/?/, "/").sub(/\/?$/, "")

    keys = []
    special_chars = %w{. + ( )}

    pattern =
      path.to_str.gsub(/((:\w+)|[\*#{special_chars.join}])/) do |match|
        case match
        when "*"
          keys << 'splat'
          "(.*?)"
        when *special_chars
          Regexp.escape(match)
        else
          keys << $2[1..-1]
          "([^/?#]+)"
        end
      end

    [/^#{pattern}$/, keys]
  end


  ##
  # Define the short version of the view for this resource.
  # Used by default on the list method.

  def self.preview view_class=nil
    return @preview unless view_class
    @preview = view_class
  end


  ##
  # Define the view to render for this resource.
  # Used by default on all methods but list.

  def self.view view_class=nil
    return @view unless view_class
    @view = view_class
  end


  ##
  # Create a new resource instance for the request.

  def initialize app=nil
    @app = app
  end


  ##
  # Call the resource with a Rack env hash.

  def call env
    mname, @params = validate! env
    #return 510 unless self.respond_to? mname
    self.__send__(mname)
  end


  ##
  # Validate the incoming request.
  # Returns the method name to call and the parsed params.

  def validate! env
  end
end
