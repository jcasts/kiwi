##
# Standard Kiwi request hooks.

module Kiwi::Hooks

  ##
  # Create an after filter. Called after serialization.

  def after &block
    hook(:after, &block)
  end


  ##
  # Create a before filter. Called after resource and
  # serializer have been identified but before validation.

  def before &block
    hook(:before, &block)
  end


  ##
  # Create a post-processing filter. Called after resource returns state data,
  # but before serialization.

  def postprocess &block
    hook(:postprocess, &block)
  end


  ##
  # Assign an arbitrary hook for error or status handling.
  # Takes an Exception class, a status code, a symbol, string,
  # or a range of status codes as arguments.
  #   hook(:before){ "DO SOMETHING FIRST" }
  #   hook(:postprocess){ "DO SOMETHING WITH RESOURCE DATA" }
  #   hook(:after){ "DO SOMETHING LAST" }
  #   hook(404){ "OH NOES" }
  #   hook(502..504, 599){ "EVIL GATEWAY" }
  #   hook(MyException){ "do something special" }
  #
  # Error hooks are called when an exception is raised,
  # but before the `after' hook.

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
