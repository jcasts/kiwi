class Kiwi::View::Error < Kiwi::View

  string :error
  string :message
  string :status
  string :backtrace, :optional => true
end
