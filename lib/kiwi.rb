class Kiwi
  require 'kiwi/core_ext'
  require 'kiwi/view'
  require 'kiwi/view/attribute'

  # This gem's version.
  VERSION = '1.0.0'

  # Standard Kiwi runtime error.
  class Error < RuntimeError; end

  # Value was not valid according to requirements.
  class InvalidTypeError < Error; end

  # Value was missing or nil.
  class RequiredValueError < Error; end

  # Something bad happenned with the request.
  class HTTPError < Error;               STATUS = 500; end

  # The route requested does not exist.
  class RouteNotFound < HTTPError;       STATUS = 404; end

  # The route requested exists but has no controller.
  class RouteNotImplemented < HTTPError; STATUS = 501; end


  class << self
    attr_accessor :trace
  end


  ##
  # Assign any constant with a value.

  def self.assign_const name, value
    consts = name.to_s.split("::")
    name   = consts.pop
    parent = find_const consts

    parent.const_set name.capitalize, value
  end


  ##
  # Find any constant.

  def self.find_const consts
    consts = consts.split("::") if String === consts
    curr   = Object

    until consts.empty? do
      const = consts.shift
      next if const.to_s.empty?

      curr = curr.const_get const.to_s
    end

    curr
  end
end

Kiwi.trace = true if ENV['RACK_ENV'] =~ /^dev/
