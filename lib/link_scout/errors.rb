module LinkScout
  # Raised whenever the given params dont match the expected input.
  class InvalidUsageError < RuntimeError; end
  class RedirectLoopError < ArgumentError; end
end
