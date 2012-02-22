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
    @path        = parse_path path
    @info_path   = parse_info_path path
    @action      = action

    @view        = nil
    @description = nil
    @params      = {} # Replace with API validator instance

    yield self if block_given?
  end


  ##
  # Check that this endpoint supports the request of the given env.

  def routes? env
    @http_method == env['HTTP_METHOD'] && env['REQUEST_PATH'] =~ @path
  end


  def validate! env
    # raise BadRequest on failure
  end


  def http_method= new_meth
    @http_method = new_meth.to_s.upcase
  end


  def path= new_path
    @path_name = new_path
    @path = parse_path new_path
  end


  def parse_path path
  end


  def info
  end
end
