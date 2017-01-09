module SocialMedia::Service
  require 'koala'

  class Facebook < Base
    def self.name
      :facebook
    end

    def delete_message message_id
      result = client.delete_object message_id
      result['success']
    end

    def upload_profile_cover filename
      raise_not_provided_error
    end

    def remove_profile_cover
      raise_not_provided_error
    end

    def upload_profile_avatar filename
      raise_not_provided_error
    end

    def remove_profile_avatar
      raise_not_provided_error
    end

    private

    def cast_error error
      return ::SocialMedia::Error::Unauthorized if error.is_a? ::Koala::Facebook::AuthenticationError
    end

    def client
      @client ||= ::Koala::Facebook::API.new(connection_params[:access_token])
    end

    def send_text_message message, options = {}
      handle_error do
        result = client.put_connections("me", "feed", options.merge(message: message))
        result['id']
      end
    end

    def send_multipart_message message, options
      media_ids = Array(options.delete(:filename)).map{ |fn| client.put_picture(fn, { published: false })['id'] }
      media_ids += Array(options.delete(:filenames)).map{ |fn| client.put_picture(fn, { published: false })['id'] }
      attached_multiparts = media_ids.inject({}) do |ids, val|
        ids["attached_media[#{media_ids.index(val)}]"] = "{ media_fbid: #{val} }"
        ids
      end
      send_text_message message, options.merge(attached_multiparts)
    end
  end
end
