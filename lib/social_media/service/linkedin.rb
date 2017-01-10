module SocialMedia::Service
  class Linkedin < Base
    def self.name
      :linkedin
    end

    def delete_message message_id
      raise_not_provided_error
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
      return Error::Unauthorized if error.is_a?(Faraday::ClientError) && (error.response[:status] == 401)
    end

    def get_api_base_url
      'https://api.linkedin.com/v1'
    end

    def client
      headers = {
        content_type: 'application/json',
        authorization: "Bearer #{connection_params[:access_token]}"
      }

      Faraday.new(url: get_api_base_url, headers: headers) do |faraday|
        faraday.request  :url_encoded
        faraday.response :raise_error
        faraday.adapter  Faraday.default_adapter
      end
    end

    def send_text_message message, options
      body = { comment: message, visibility: { code: 'anyone' } }.merge(options)
      responce = client.post 'people/~/shares?format=json' do |req|
        req.body = body.to_json
      end
      (::JSON.parse responce.body rescue {})['updateKey']
    end

    # :submitted_url - an url submitted with image
    def send_multipart_message message, options
      raise_not_provided_error if options.delete(:filenames)
      media_url = options.delete(:filename)

      content = {
        content: { submitted_image_url: media_url, submitted_url: options.delete(:submitted_url) || media_url }
      }
      send_text_message message, options.merge(content)
    end
  end
end
