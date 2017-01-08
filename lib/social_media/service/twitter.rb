module SocialMedia::Service
  require 'twitter'

  class Twitter < Base
    def self.name
      :twitter
    end

    def cast_error error
      return ::SocialMedia::Error::Unauthorized if error.is_a? ::Twitter::Error::Unauthorized
    end

    def client
      @client ||= ::Twitter::REST::Client.new do |config|
        config.consumer_key = connection_params[:consumer_key]
        config.consumer_secret = connection_params[:consumer_secret]
        config.access_token = connection_params[:access_token]
        config.access_token_secret = connection_params[:access_token_secret]
      end
    end

    def send_message message, options={}
      return send_text_message(message, options) unless options.has_key? :filenames
      send_multipart_message message, options
    end

    def delete_message message_id
      result = client.destroy_status message_id
      result.first.id
    end

    def update_profile_background filename
      client.update_profile_banner(open filename)
    end

    def update_profile_image filename
      result = client.update_profile_image(open filename)
      result.id
    end

    private

    def send_text_message message, options
      handle_error do
        result = client.update(message, options)
        result.id
      end
    end

    def send_multipart_message message, options
      media = Array(options.delete(:filenames)).map{ |fn| File.new(fn) }
      handle_error do
        result = client.update_with_media(message, media, options)
        result.id
      end
    end
  end
end
