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
              :params, :view, :description

  def initialize http_method, path, action=nil
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
  # Assign an action proc.

  def action &block
    @action = block
  end


  ##
  # Assign a description.

  def desc value
    @description = value
  end


  ##
  # Access the param definition object.

  def param
    @params
  end


  ##
  # Check that this endpoint supports the request of the given env.

  def routes? env
    @http_method == env['HTTP_METHOD'] && env['REQUEST_PATH'] =~ @path
  end


  def validate! env
  end


  def parse_path path
  end


  def info
  end
end
