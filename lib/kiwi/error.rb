class Kiwi
  # Standard Kiwi runtime error.
  class Error < RuntimeError
    STATUS = 500

    def self.to_hash err, backtrace=true
      hash = {
        :error   => err.class.name,
        :message => err.message,
        :status  => (err.respond_to?(:status) ? err.status : STATUS)
      }
      hash[:backtrace] = err.backtrace if backtrace && self.backtrace

      hash
    end


    ##
    # Error code to use. Typically a HTTP status code.

    def status
      self.class::STATUS
    end


    ##
    # Build the hash representation of the Error Resource.

    def to_hash backtrace=true
      self.class.to_hash self, backtrace
    end
  end

  # Error while validating input or output field.
  class ValidationError < Error; STATUS = 400; end

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
  class BadRequest < HTTPError;           STATUS = 400; end

  # The route requested does not exist.
  class ResourceNotFound < HTTPError;     STATUS = 404; end

  # The method requested is not available for the given resource.
  class MethodNotAllowed < HTTPError;     STATUS = 405; end

  # The Accept header type is not available for the given resource.
  class NotAcceptable < HTTPError;        STATUS = 406; end

  # The route requested exists but has no controller.
  class NotImplemented < HTTPError;       STATUS = 501; end
end
