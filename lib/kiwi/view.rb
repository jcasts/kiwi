##
# Defines a View and validates data before rendering.

class Kiwi::View < Kiwi::Validator

  ##
  # Reference another view.

  def self.view name, klass, opts={}
    v_attribute name, klass, opts
  end
end
