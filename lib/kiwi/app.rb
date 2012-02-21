##
# Defines the application and handles requests.

class Kiwi::App

  #TODO: before, after, and error hooks

  attr_reader :endpoints, :hooks


  def initialize
    @endpoints = {}
  end


  def call env
    Kiwi::Request.new(self, env).call
  end
end
