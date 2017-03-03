require 'spec_helper'

RSpec.describe SocialMedia::Service::Linkedin do
  include_context "shared_image_fixtures"
  context "class methods" do
    subject { described_class }
    its(:name) { is_expected.to eq :linkedin }
  end

  if service_configured? described_class.name
    let(:service) { described_class.new service_configurations[described_class.name] }
    subject { service }

    it "instantiates" do
      expect(subject).to be_a SocialMedia::Service::Linkedin
    end
    its(:connection_params) { is_expected.to include :client_id }
    its(:connection_params) { is_expected.to include :client_secret }
    its(:connection_params) { is_expected.to include :access_token }

    context "invalid token error" do
      let(:service) { described_class.new service_configurations[described_class.name] }
      before { service.connection_params[:access_token] = 'bogus' }
      subject { service }

      it "wraps the LinkedIn specific error" do
        with_cassette :linkedin, :invalid_token do
          expect{subject.send_message("This is a test")}.to raise_error SocialMedia::Error::Unauthorized, 'Faraday::ClientError: the server responded with status 401'
        end
      end
    end

    describe "sending a text message" do
      it "can send a message" do
        with_cassette :linkedin, :send_text do
          expect(subject.send_message("This is a test")).to match /UPDATE-\d+\-\d+/
        end
      end
    end

    describe "sending a message with images" do
      it "can send a message with one image" do
        with_cassette :linkedin, :send_image do
          expect(subject.send_message("Testing image upload", filename: chrome_image_path)).to match /UPDATE-\d+\-\d+/
        end
      end

      it "can send a message with one image and submitted_url" do
        with_cassette :linkedin, :send_image_and_url do
          expect(subject.send_message("Testing image upload", filename: chrome_image_path, submitted_url: 'http://example.com')).to match /UPDATE-\d+\-\d+/
        end
      end

      it "can send a message with multiple images" do
        filenames = [chrome_image_path, firefox_image_path, ie_image_path]
        with_cassette :linkedin, :send_images do
          expect{subject.send_message("Testing multiple image uploads", filenames: filenames)}.to \
            raise_error SocialMedia::Error::NotProvided, "SocialMedia::Service::Linkedin#send_multipart_message"
        end
      end
    end

    describe "deleting a message" do
      it "can delete a message" do
        with_cassette :linkedin, :delete_message do
          message_id = subject.send_message("This is a test")
          expect{subject.delete_message(message_id)}.to \
            raise_error SocialMedia::Error::NotProvided, "SocialMedia::Service::Linkedin#delete_message"
        end
      end
    end

    describe "Profile" do
      it "can upload a profile cover image" do
        with_cassette :linkedin, :upload_profile_cover do
          expect{subject.upload_profile_cover wallpaper_image_path}.to \
            raise_error SocialMedia::Error::NotProvided, "SocialMedia::Service::Linkedin#upload_profile_cover"
        end
      end

      it "can remove a profile cover image" do
        with_cassette :linkedin, :remove_profile_cover do
          expect{subject.remove_profile_cover}.to \
            raise_error SocialMedia::Error::NotProvided, "SocialMedia::Service::Linkedin#remove_profile_cover"
        end
      end

      it "can upload a profile avatar image" do
        with_cassette :linkedin, :upload_profile_avatar do
          expect{subject.upload_profile_avatar chrome_image_path}.to \
            raise_error SocialMedia::Error::NotProvided, "SocialMedia::Service::Linkedin#upload_profile_avatar"
        end
      end

      it "can remove a profile avatar image" do
        expect{subject.remove_profile_avatar}.to \
          raise_error SocialMedia::Error::NotProvided, "SocialMedia::Service::Linkedin#remove_profile_avatar"
      end
    end
  end
end
