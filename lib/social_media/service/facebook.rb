# Get your tokens on
# https://developers.facebook.com/docs/facebook-login/access-tokens

# Activate your App
# http://stackoverflow.com/questions/30085246/app-not-setup-this-app-is-still-in-development-mode

# Working with pages: https://developers.facebook.com/docs/graph-api/reference/page
module SocialMedia::Service
  require 'koala'

  class Facebook < Base
    class PageNotFoundError < Error; end

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
      # The Marketing API should be enabled for the APP to use this feature
      raise_not_provided_error unless switch_to_page

      media_info = page_client.put_picture(filename)
      page_client.put_connections("me", "/", { cover: media_info['id'] })
    end

    # AFAIK, profile covers only provided on pages, not users
    def remove_profile_cover
      # The Marketing API should be enabled for the APP to use this feature
      raise_not_provided_error unless switch_to_page

      page = page_client.get_object('me', fields: 'cover')
      cover = page['cover']
      page_client.delete_object(cover['cover_id']) if cover
    end

    # AFAIK, profile avatars only provided on pages, not users
    def upload_profile_avatar filename
      # The Marketing API should be enabled for the APP to use this feature
      # A publish_pages permission is required.
      raise_not_provided_error unless switch_to_page

      media_info = page_client.put_picture filename
      picture_url = page_client.get_picture_data(media_info['id'])['data']['url']
      page_client.put_connections('me', 'picture', { picture: picture_url })
    end

    # AFAIK, profile avatars only provided on pages, not users
    def remove_profile_avatar
      # Warning: it removes all Page's profile pictures
      # The Marketing API should be enabled for the APP to use this feature
      # A publish_pages permission is required.
      raise_not_provided_error unless switch_to_page
      # The above guard stays in place...implement the TODO logic below.

      profile_pictures = page_client.get_connections('me', 'photos', type: 'profile')
      page_client.batch do |batch|
        profile_pictures.each { |picture| batch.delete_object(picture['id']) }
      end
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

      page_name = connection_params[:page_name]
      page_id = connection_params[:page_id]

      accounts = client.get_connections('me', 'accounts')

      # Find the page by name when page_name is present
      page_account = accounts.find { |account| account['name'] == page_name } if page_name

      # Otherwise find the page by page_id
      page_account ||= accounts.find { |account| account['id'] == page_id } if page_id

      # If page_name is given and it doesn't exist, create it
      page_account ||= create_page(page_name) if page_name

      unless page_account
        raise PageNotFoundError.new("The page is not found and cannot be created")
      end

      connection_params[:page_access_token] = page_account['access_token']
    end

    def create_page(page_name)
      # Please note:
      # Only applications with Standard API Access to Marketing API can create Pages
      # Also, ads_management, manage_pages, publish_pages, and business_management
      # permissions are required.
      # More info:
      # https://developers.facebook.com/docs/marketing-api/access
      # https://developers.facebook.com/docs/graph-api/reference/page/
      #
      # Unfortunately, currently it's imposible to create a page via the FB API without
      # the Marketing API's Standard API Access.

      client.put_connections("me", "accounts", {name: page_name})
    end

    def initialize_client
      set_api_version
      get_app_access_token
      Koala::Facebook::API.new connection_params[:user_access_token], connection_params[:app_secret]
    end

    def client
      @client ||= initialize_client
    end

    def page_client
      @page_client ||= Koala::Facebook::API.new connection_params[:page_access_token]
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
