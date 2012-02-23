##
# Defines the application and handles requests.

class Kiwi::App


  def self.apps
    @apps ||= []
  end


  def self.descendants
    child_apps = @apps.dup
    @apps.each do |app|
      child_apps.concat  app.descendants
    end
    child_apps
  end


  def self.inherited subclass
    hooks.merge! subclass.hooks
    apps << subclass
  end


  extend Kiwi::DSL


  attr_reader :endpoints, :hooks


  def initialize
    @hooks     = self.class.hooks
    @endpoints = {}

    self.class.endpoints.each do |verb, epts|
      @endpoints[verb] = epts.map{|ept| [ept, self] }
    end

    unless self.class.apps.empty?
      self.class.apps.each do |app_klass|
        next if app_klass.endpoints.empty?
        app = app_klass.new
        @endpoints.concat app.endpoints
      end
    end
  end


  def call env
    Kiwi::Request.new(self, env).call
  end
end
