class Kiwi::View

  @view_attributes = {}

  def self.view_attr path, type, opts={}
    path = path.split("/") if String === path
    @view_attributes[path] = Attribute.new type, opts={}
  end


  def self.build obj
  end


  def initialize
    @value = {}
  end


  def to_hash
    @value
  end
end
