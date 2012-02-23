##
# Standard Kiwi request hooks.

module Kiwi::Hooks

  ##
  # Called after action is called, before render is called.

  def after &block
    hook(:after, &block)
  end

  ##
  # Called before routing exceptions and action is called, but after
  # endpoint has been determined (or found non-existant).

  def before &block
    hook(:before, &block)
  end


  ##
  # Called when an error is triggered. Takes an Exception class, a status code,
  # or a range of status codes as arguments.
  #   error(404){ "OH NOES" }
  #   error(502..504, 599){ "EVIL GATEWAY" }
  #   error(MyException){ "do something special" }
  #
  # Error hooks are called when an exception is raised,
  # but before the `after' hook.

  def error *errors, &block
    hook(*errors, &block)
  end


  ##
  # Assign an arbitrary hook for error or status handling.

  def hook *names, &block
    names.each do |name|
      if Range === name
        name.each{|n| hooks[n] = block }
      else
        hooks[name] = block
      end
    end
  end


  ##
  # Named set of hooks.

  def hooks
    @hooks ||= {}
  end
end
