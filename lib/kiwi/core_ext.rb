if defined?(Boolean)
  $stderr.puts \
   "WARNING! Boolean is already defined. Kiwi may not work correctly."

else
  module Boolean; end
  TrueClass.send :include, Boolean
  FalseClass.send :include, Boolean
end


class Exception
if instance_methods.include?(:to_hash)
  $stderr.puts \
   "WARNING! Exception#to_hash is already defined. Kiwi may not work correctly."

else
  def to_hash backtrace=true
    hash = {
      :message => self.message,
      :error   => self.class.name
    }
    hash[:backtrace] = self.backtrace if self.backtrace

    hash
  end
end
end
