module SocialMedia
  module Service
    class Base
      def self.name
        raise NotImplementedError.new "#{self.to_s}::name not implemented"
      end

      attr_reader :connection_params

      def initialize connection_params
        @connection_params = connection_params
      end

      def cast_error error
        return Error
      end
      
      def handle_error &block
        begin
          yield
        rescue Exception => error
          wrapped_error = SocialMedia::convert_exception_class(error, cast_error(error) || Error)
          raise wrapped_error
        end
      end
    end
  end
end
