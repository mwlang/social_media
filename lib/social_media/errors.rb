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

  Unauthorized = Class.new(Error)
  Error::Unauthorized = Unauthorized

  NotProvided = Class.new(Error)
  Error::NotProvided = NotProvided
end
