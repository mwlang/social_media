module SocialMedia
  def self.convert_exception_class exception, klass
    return exception if exception.is_a?(klass)
    e = klass.new("#{exception.class}: #{exception.message}")
    e.wrapped_exception = exception
    e.set_backtrace(exception.backtrace)
    e
  end

  class Error < ::StandardError
    # If this exception wraps an underlying exception, the underlying
    # exception is held here.
    attr_accessor :wrapped_exception
  end

  # Invalid credentials, expired tokens, etc.
  Unauthorized = Class.new(Error)
  Error::Unauthorized = Unauthorized

  # Features of service that may be allowed to fail silently
  NotProvided = Class.new(Error)
  Error::NotProvided = NotProvided

  # Features of the service that are not yet implemented (but should be)
  NotImplemented = Class.new(Error)
  Error::NotImplemented = NotImplemented
end
