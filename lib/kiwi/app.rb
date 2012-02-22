##
# Defines the application and handles requests.

class Kiwi::App

  extend Kiwi::DSL

  attr_reader :endpoints, :hooks


  def initialize
    @endpoints = self.class.endpoints
    @hooks     = self.class.hooks
  end


  def call env
    Kiwi::Request.new(self, env).call
  end
end
