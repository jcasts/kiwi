require 'rack'

class Kiwi

  # This gem's version.
  VERSION = '1.0.0'


  class << self
    attr_accessor :trace
    attr_accessor :enforce_desc
    attr_accessor :force_mime_type
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
require 'kiwi/error'
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
require 'kiwi/link'
require 'kiwi/resource'
require 'kiwi/resource/resource'
require 'kiwi/resource/link'
require 'kiwi/resource/app'
require 'kiwi/resource/attribute'
require 'kiwi/resource/error'
require 'kiwi/adapter/rack'
require 'kiwi/app'
require 'kiwi/init'
