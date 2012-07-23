##
# Standard Kiwi request hooks.

module Kiwi::Hooks

  ##
  # Create an after filter. Called after serialization, once
  # the Rack response is built.

  def after &block
    hook(:after, &block)
  end


  ##
  # Create a before filter. Called after resource and
  # serializer have been identified.

  def before &block
    hook(:before, &block)
  end


  ##
  # Create a post-processing filter. Called after resource returns state,
  # but before serialization.

  def postprocess &block
    hook(:postprocess, &block)
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
        name.each{|n| (hooks[n] ||= []) << block }
      else
        (hooks[name] ||= []) << block
      end
    end
  end


  ##
  # Named set of hooks.

  def hooks
    @hooks ||= {}
  end
end
