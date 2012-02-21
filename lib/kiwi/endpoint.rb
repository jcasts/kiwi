##
# Describes an application endpoint.

class Kiwi::Endpoint

  attr_accessor :action, :http_method, :path, :path_name
                :params, :view, :description

  def initialize http_method, path
    @http_method = http_method.to_s.upcase
    @path_name   = path
    @path        = parse_path path
    @info_path   = parse_info_path path
    @action      = action

    @view        = nil
    @description = nil
    @params      = {}

    yield self if block_given?
  end


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
