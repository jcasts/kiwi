##
# Defines the application and handles requests.

class Kiwi::App

  attr_reader :endpoints, :hooks


  def initialize
    @endpoints = {}
    @hooks = self.class.hooks
  end


  def call env
    Kiwi::Request.new(self, env).call
  end


  class << self
    attr_accessor :hooks
  end

  ##
  # Assign a hook for error or status handling.
  #   hook(404){ "OH NOES" }
  #   hook(502..504, 599){ "EVIL GATEWAY" }
  #   hook(MyException){ "do something special" }

  def self.hook *names, &block
    @hooks ||= {}
    names.each do |name|
      if Range === name
        name.each{|n| @hooks[n] = block }
      else
        @hooks[name] = block
      end
    end
  end
end
