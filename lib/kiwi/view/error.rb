class Kiwi::View::Error < Kiwi::View

  string  :error
  integer :status
  string  :message,   :optional => true
  string  :backtrace, :optional => true, :collection => true
end
