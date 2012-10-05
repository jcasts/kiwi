class Kiwi
  # Standard Kiwi runtime error.
  class Error < RuntimeError
    STATUS = 'InternalServerError'

    ##
    # Error code to use. Typically a HTTP status code.

    def status
      self.class::STATUS
    end


    ##
    # Build the hash representation of the Error Resource.

    def to_hash backtrace=true
      hash = super
      hash[:status] = self.status
      hash
    end
  end

  # Error while validating input or output field.
  class ValidationError < Error; end

  # Value was not valid according to requirements.
  class InvalidTypeError < ValidationError; end

  # Value was not in the specified set.
  class BadValueError < ValidationError; end

  # Value was missing or nil.
  class RequiredValueError < ValidationError; end

  # Unexpected param was given to a ParamSet
  class InvalidParam < ValidationError; end

  # Something bad happenned with the request.
  class HTTPError < Error; end

  # The request made to the endpoint was invalid.
  class BadRequest < HTTPError;           STATUS = 'BadRequest'; end

  # The route requested does not exist.
  class ResourceNotFound < HTTPError;     STATUS = 'NotFound'; end

  # The method requested is not available for the given resource.
  class MethodNotAllowed < HTTPError;     STATUS = 'MethodNotAllowed'; end

  # The Accept header type is not available for the given resource.
  class NotAcceptable < HTTPError;        STATUS = 'NotAcceptable'; end

  # The route requested exists but has no controller.
  class NotImplemented < HTTPError;       STATUS = 'NotImplemented'; end
end
