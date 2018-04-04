module LinkScout
  # Raised whenever the given params dont match the expected input.
  class InvalidUsageError < RuntimeError; end

  # Raised on Redirect Loops
  class RedirectLoopError < ArgumentError; end
end
