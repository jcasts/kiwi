module Kiwi::Adapter

  ##
  # Rack env request adapter for Kiwi.
  # Adapters must respond to :request and :response.

  class Rack

    ##
    # Must return a hash with the following keys:
    #
    # * kiwi.mime:        The mime-type requested by the client.
    # * kiwi.params:      The request params.
    # * kiwi.path:        The request path (e.g. PATH_INFO).
    # * kiwi.method:      The request method (e.g. REQUEST_METHOD).

    def self.request env
      env['kiwi.mime']   = env['HTTP_ACCEPT']
      env['kiwi.params'] = ::Rack::Request.new(env).params
      env['kiwi.path']   = env['PATH_INFO']
      env['kiwi.method'] = env['REQUEST_METHOD'].downcase.to_sym
      env
    end


    ##
    # Must return a format compatible with the library or protocol used,
    # e.g. [status, headers, body]
    #
    # The env argument will contain a the 'kiwi.content_type' key, specifying
    # the mime-type of the body, and the 'kiwi.status' key, containing the
    # status code of the response.

    def self.response env, body
      body = [ body ] unless body.respond_to? :each
      [ env['kiwi.status'],
        {'Content-type' => env['kiwi.content_type']},
        body ]
    end
  end
end
