# Get your tokens on
# https://developers.facebook.com/docs/facebook-login/access-tokens

# Activate your App
# http://stackoverflow.com/questions/30085246/app-not-setup-this-app-is-still-in-development-mode

# Working with pages: https://developers.facebook.com/docs/graph-api/reference/page
module SocialMedia::Service
  require 'koala'

  class Facebook < Base
    def self.name
      :facebook
    end

    def delete_message message_id
      handle_error do
        result = client.delete_object message_id
        result['success']
      end
    end

    # AFAIK, profile covers only provided on pages, not users
    def upload_profile_cover filename
      raise_not_provided_error unless switch_to_page
      # The above guard stays in place...implement the TODO logic below.

      raise_not_implemented_error
      #TODO: implement setting a page's profile cover
    end

    # AFAIK, profile covers only provided on pages, not users
    def remove_profile_cover
      raise_not_provided_error unless switch_to_page
      # The above guard stays in place...implement the TODO logic below.

      raise_not_implemented_error
      #TODO: implement deleting a page's profile cover
    end

    # AFAIK, profile avatars only provided on pages, not users
    def upload_profile_avatar filename
      raise_not_provided_error unless switch_to_page
      # The above guard stays in place...implement the TODO logic below.

      raise_not_implemented_error
      #TODO: implement adding the page's avatar image (aka image/logo/icon)
    end

    # AFAIK, profile avatars only provided on pages, not users
    def remove_profile_avatar
      raise_not_provided_error unless switch_to_page
      # The above guard stays in place...implement the TODO logic below.

      raise_not_implemented_error
      #TODO: implement removing the page's avatar image (aka image/logo/icon)
    end

    # Currently, user_access_token *must* be provided...
    def get_access_token
      connection_params[:user_access_token]
      get_app_access_token
      # we are able to get the app access token, but acquiring a user access token requires a browser session
      # that the user can log into Facebook via OAuth.  The page then redirects back with the code
      # At the moment, I do not have a sane strategy for implementing at a library level.  The only way
      # forward is to build out the Rails functionality of this gem and implement controller actions to
      # handle the login/redirect flow
      raise Error::NotImplemented.new "cannot implement get_access_token without browser session"
      @oauth.url_for_oauth_code
    end

    private

    def cast_error error
      return Error::Unauthorized if error.is_a? Koala::Facebook::AuthenticationError
    end

    def callback_url
      connection_params[:callback_url] || 'http://localhost:3000'
    end

    def set_api_version
      Koala.config.api_version = "v2.2"
    end

    # A long-term app_access_token might be supplied on connection parameters
    # If not, we fetch a short-term one here.
    def get_app_access_token
      return connection_params[:app_access_token] if connection_params.has_key? :app_access_token

      @oauth = Koala::Facebook::OAuth.new(connection_params[:app_id], connection_params[:app_secret], callback_url)
      connection_params[:app_access_token] = @oauth.get_app_access_token
    end

    def switch_to_page
      return unless connection_params.has_key?(:page_name) || connection_params.has_key?(:page_id)
      # The above guard stays in place...implement the TODO logic below.

      raise_not_implemented_error
      #TODO: find the page by name when page_name is present
      #TODO: otherwise find the page by page_id
      #TODO: if page_name is given and it doesn't exist, create it
    end

    def initialize_client
      set_api_version
      get_app_access_token
      Koala::Facebook::API.new connection_params[:user_access_token], connection_params[:app_secret]
    end

    def client
      @client ||= initialize_client
    end

    def send_text_message message, options = {}
      result = client.put_connections("me", "feed", options.merge(message: message))
      result['id']
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
