Kiwi.trace = !!(ENV['RACK_ENV'] =~ /^dev/i)

Kiwi.input_types = {
  String  => :to_s,
  Integer => :to_i,
  Float   => :to_f,
  Boolean => lambda{|val| !(val =~ /^(0|false|F|N|no|nil|null|undefined|)$/i) }
}
