module Kiwi::Adapter
  ##
  # Rack env request adapter for Kiwi.
  # Must return a hash with the following keys:
  #
  # * kiwi.mime:        The mime-type requested by the client.
  # * kiwi.params:      The request params.
  # * kiwi.path:        The request path (e.g. PATH_INFO).
  # * kiwi.method:      The request method (e.g. REQUEST_METHOD).

  class Rack
    def self.call env
      env['kiwi.mime']       = env['HTTP_ACCEPT']
      env['kiwi.params']     = ::Rack::Request.new(env).params
      env['kiwi.path']       = env['PATH_INFO']
      env['kiwi.method']     = env['REQUEST_METHOD'].downcase.to_sym
      env
    end
  end
end
