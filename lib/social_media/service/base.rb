module SocialMedia
  module Service
    class Base
      Error = SocialMedia::Error

      def self.name
        raise NotImplementedError.new "#{self.to_s}::name not implemented"
      end

      # :filenames - array of filenames that can be loaded and sent with text message
      # :filename - a single filename that can be loaded and sent with text message
      def send_message message, options={}
        handle_error do
          if options.has_key?(:filenames) || options.has_key?(:filename)
            send_multipart_message message, options
          else
            send_text_message(message, options)
          end
        end
      end

      attr_reader :connection_params
      attr_reader :not_provided_behavior

      def initialize connection_params
        @connection_params = connection_params
        @not_provided_behavior = connection_params.delete(:not_provided_behavior) || :raise_error
      end

      def cast_error error
        return Error
      end

      def raise_not_provided_error
        return if not_provided_behavior == :silent

        method_name = caller.first.scan(/\:in \`(.*)\'$/).join
        raise SocialMedia::Error::NotProvided.new "#{self.class.to_s}##{method_name}"
      end

      def raise_not_implemented_error
        method_name = caller.first.scan(/\:in \`(.*)\'$/).join
        raise SocialMedia::Error::NotImplemented.new "#{self.class.to_s}##{method_name}"
      end

      def handle_error &block
        begin
          yield
        rescue Exception => error
          wrapped_error = SocialMedia::convert_exception_class(error, cast_error(error) || Error)
          raise wrapped_error
        end
      end

      private

      def send_text_message message, options
        raise_not_provided_error
      end

      def send_multipart_message message, options
        raise_not_provided_error
      end

    end
  end
end
