require 'rack'

class Kiwi

  # This gem's version.
  VERSION = '1.0.0'

  # Standard Kiwi runtime error.
  class Error < RuntimeError; end

  # Error while validating input or output field.
  class ValidationError < Error; end

  # Value was not valid according to requirements.
  class InvalidTypeError < ValidationError; end

  # Value was missing or nil.
  class RequiredValueError < ValidationError; end

  # Unexpected param was given to a ParamSet
  class InvalidParam < ValidationError; end

  # Something bad happenned with the request.
  class HTTPError < Error;                STATUS = 500; end

  # The request made to the endpoint was invalid.
  class BadRequest < HTTPError;           STATUS = 400; end

  # The route requested does not exist.
  class RouteNotFound < HTTPError;        STATUS = 404; end

  # The method requested is not available for the given resource.
  class MethodNotAllowed < HTTPError;     STATUS = 405; end

  # The Accept header type is not available for the given resource.
  class NotAcceptable < HTTPError;        STATUS = 406; end

  # The route requested exists but has no controller.
  class RouteNotImplemented < HTTPError;  STATUS = 501; end


  class << self
    attr_accessor :trace
    attr_accessor :enforce_desc
    attr_accessor :force_accept_header
    attr_accessor :input_types
    attr_accessor :param_validation
    attr_accessor :http_verbs
    attr_accessor :default_http_verb
    attr_accessor :route_delim
    attr_accessor :serializers
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

  rescue NameError
    nil
  end
end

require 'kiwi/core_ext'
require 'kiwi/validator'
require 'kiwi/validator/attribute'
require 'kiwi/param'
require 'kiwi/param_set'
require 'kiwi/view'
require 'kiwi/view/attribute'
require 'kiwi/view/link'
require 'kiwi/view/app'
require 'kiwi/view/error'
require 'kiwi/view/resource'
require 'kiwi/hooks'
require 'kiwi/route'
require 'kiwi/resource'
require 'kiwi/resource/resource'
require 'kiwi/resource/link'
require 'kiwi/resource/app'
require 'kiwi/resource/attribute'
require 'kiwi/resource/error'
require 'kiwi/app'
require 'kiwi/init'
