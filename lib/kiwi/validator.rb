##
# Validates sets and nested sets of data.

module Kiwi::Validator

  attr_accessor :optional_flag


  ##
  # Define an Boolean validator attribute.

  def boolean name, opts={}
    v_attribute name, Boolean, opts
  end


  ##
  # Define a collection of sub-attributes.
  # Will create an anonymous Validator and yield it to the block.
  #
  #   collection :records, :optional => true do |foo|
  #     foo.integer :score
  #     foo.string  :name
  #   end

  def collection name, opts={}, &block
    subset name, opts.merge(:collection => true), &block
  end


  ##
  # Define an Integer validator attribute.

  def integer name, opts={}
    v_attribute name, Integer, opts
  end


  ##
  # Define a String validator attribute.

  def string name, opts={}
    v_attribute name, String, opts
  end


  ##
  # Define a collection of sub-attributes.
  # Will create an anonymous Validator and yield it to the block.
  #
  #   subset :address, :optional => true do |addr|
  #     addr.string :zip
  #     addr.string :city
  #     addr.string :street
  #   end

  def subset name, opts={}
    v_attribute name, opts do |validator_klass|
      yield validator_klass
    end
  end


  ##
  # Reference another validator.

  def validator name, klass, opts={}
    v_attribute name, klass, opts
  end


  ##
  # Assign an attribute name with a type
  # Supports any option of Kiwi::Validator::Attribute.new

  def v_attribute name, type, opts={}
    opts, type = type, nil if Hash === type

    opts = {:optional => optional_flag}.merge opts if optional_flag

    if block_given?
      type = subvalidator
      yield type
    end

    name = name.to_s
    assign_attribute new_attribute(name, type, opts), opts
  end


  ##
  # Everything after calling this method is an optional attribute.
  #   class MyValidator < Kiwi::Validator
  #     string :required_key
  #
  #     optional
  #     string :optional_key
  #   end

  def optional
    self.optional_flag = true
  end


  ##
  # Everything after calling this method is a required attribute.
  #   class MyValidator < Kiwi::Validator
  #     string :required_key
  #
  #     optional
  #     string :optional_key
  #
  #     required
  #     string :other_required_key
  #   end

  def required
    self.optional_flag = false
  end


  ##
  # Build the validator from an object or hash.

  def build obj
    value = {}

    v_attributes.each do |name, attrib|
      val = attrib.value_from obj
      value[name.to_sym] = val unless val.nil? && attrib.optional
    end

    value
  end


  ##
  # Return an array hashes of v_attributes.

  def to_a
    v_attributes.values.map(&:to_hash)
  end
end
