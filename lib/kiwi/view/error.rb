class Kiwi::View::Error < Kiwi::View

  string :error
  string :message
  string :backtrace, :optional => true
end
