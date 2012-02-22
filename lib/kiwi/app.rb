##
# Defines the application and handles requests.

class Kiwi::App

  extend Kiwi::DSL

  attr_reader :endpoints, :hooks


  def initialize
    @endpoints = self.class.endpoints
    @hooks     = self.class.hooks
    @apps      = {}

    if self.class == Kiwi::App
      @@apps.each{|app| @apps[app] = app.new }
    end
  end


  def call env
    Kiwi::Request.new(self, env).call
  end


  def self.apps
    @@apps ||= []
  end


  def self.inherited subclass
    (@@apps ||= []) << subclass
  end
end
