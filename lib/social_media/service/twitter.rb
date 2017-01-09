module SocialMedia::Service
  require 'twitter'

  class Twitter < Base
    def self.name
      :twitter
    end

    def cast_error error
      return ::SocialMedia::Error::Unauthorized if error.is_a? ::Twitter::Error::Unauthorized
    end

    def reset_client
      @client = nil
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
      return send_text_message(message, options) unless options.has_key?(:filenames) || options.has_key?(:filename)
      send_multipart_message message, options
    end

    def delete_message message_id
      result = client.destroy_status message_id
      result.first.id
    end

    def upload_profile_background filename
      client.update_profile_banner(open_file filename)
    end

    def upload_profile_avatar filename
      result = client.update_profile_image(open_file filename)
      result.id
    end

    private

    # The Twitter gem is particular about the type of IO object it
    #   recieves when tweeting an image. If an image is < 10kb, Ruby opens it as a
    #   StringIO object. Which is not supported by the Twitter gem/api.
    #
    #   This method ensures we always have a valid IO object for Twitter.
    def open_file filename
      image_file = open(filename)
      return image_file unless image_file.is_a?(StringIO)

      base_name = File.basename(filename)
      temp_file = Tempfile.new(base_name)

      temp_file.binmode
      temp_file.write(image_file.read)
      temp_file.close

      open(temp_file.path)
    end

    def send_text_message message, options
      handle_error do
        result = client.update(message, options)
        result.id
      end
    end

    def send_multipart_message message, options
      media_ids = Array(options.delete(:filename)).map{ |fn| client.upload open_file(fn) }
      media_ids += Array(options.delete(:filenames)).map{ |fn| client.upload open_file(fn) }
      send_text_message message, options.merge(media_ids: media_ids.join(","))
    end
  end
end
