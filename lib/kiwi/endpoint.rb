##
# Describes an application endpoint.
#
# Support this:
#  desc "Get a specific foo"
#  string :id, "The id of the foo"
#
#  get "/foo/:id" do
#    # do something
#  end

class Kiwi::Endpoint

  attr_reader :http_method, :path, :path_name

  attr_accessor :action, :params, :view, :description

  def initialize http_method, path, &action
    @http_method = http_method.to_s.upcase
    @path_name   = path
    @path, @keys = parse_path path
    @action      = action

    @view        = nil
    @description = nil
    @params      = Class.new Kiwi::Validator

    yield self if block_given?
  end


  ##
  # Call the endpoint with the given Kiwi::Request instance.

  def call kreq
    yield_params = keys.map{|key| kreq.params[key]}
    kreq.instance_exec(*yield_params, &@action)
  end


  ##
  # Check that this endpoint supports the request of the given env.

  def routes? env
    @http_method == env['HTTP_METHOD'] && env['REQUEST_PATH'] =~ @path
  end


  ##
  # Validate the given Kiwi::Request instance.

  def validate! kreq
    # raise BadRequest on failure
  end


  def http_method= new_meth
    @http_method = new_meth.to_s.upcase
  end


  def path= new_path
    @path_name = new_path
    @path = parse_path new_path
  end


  ##
  # Converts an endpoint path to its regex matcher.
  # (Thanks Sinatra!)

  def parse_path path
    return [path, []] if Regexp === path

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


  def info
  end
end
