require 'spec_helper'

RSpec.describe SocialMedia::Service::Facebook do
  include_context "shared_image_fixtures"
  # The page with that name should be created prior to run these specs
  # Otherwise, it will try to create a page.
  # However, it requires Standard API Access to Marketing API to create a page.
  # More information: https://developers.facebook.com/docs/marketing-api/access
  let(:page_name) { "Test_page" } # Page name should be capitalized

  context "class methods" do
    subject { described_class }
    its(:name) { is_expected.to eq :facebook }
  end

  if service_configured? described_class.name
    let(:params) { service_configurations[described_class.name] }
    let(:service) { described_class.new params }

    subject { service }

    it "instantiates" do
      expect(subject).to be_a SocialMedia::Service::Facebook
    end
    its(:connection_params) { is_expected.to include :app_id }
    its(:connection_params) { is_expected.to include :app_secret }
    its(:connection_params) { is_expected.to include :user_access_token }

    context "invalid token error" do
      let(:service) { described_class.new service_configurations[described_class.name] }
      before { service.connection_params[:user_access_token] = 'bogus' }
      subject { service }

      it "wraps the facebook specific error" do
        with_cassette :facebook, :invalid_token do
          expect{subject.send_message("This is a test")}.to \
            raise_error(SocialMedia::Error::Unauthorized) { |error| expect(error.message).to include 'code: 190', 'Invalid OAuth access token' }
        end
      end
    end

    describe ".switch_to_page" do
      context "given a page_name" do
        let(:params) { service_configurations[described_class.name].merge!(page_name: page_name) }
        its(:connection_params) { is_expected.to include :page_name }
      end
    end

    context "obtain oauth access_token" do
      it "gets access token" do
        with_cassette :facebook, :access_token do
          expect{subject.get_access_token}.to raise_error SocialMedia::Error::NotImplemented
        end
      end
    end

    describe "sending a text message" do
      it "can send a message" do
        with_cassette :facebook, :send_text do
          expect(subject.send_message("Test sending text only message")).to match /\d+\_\d+/
        end
      end
    end

    describe "sending a message with images" do
      it "can send a message with one image" do
        with_cassette :facebook, :send_image do
          expect(subject.send_message("Testing image upload", filename: chrome_image_path)).to match /\d+\_\d+/
        end
      end

      it "can send a message with multiple images" do
        filenames = [chrome_image_path, firefox_image_path, ie_image_path]
        with_cassette :facebook, :send_images do
          expect(subject.send_message("Testing multiple image uploads", filenames: filenames)).to match /\d+\_\d+/
        end
      end
    end

    describe "deleting a message" do
      it "can delete a message" do
        with_cassette :facebook, :delete_message do
          message_id = subject.send_message("This is a test")
          expect(subject.delete_message(message_id)).to eq true
        end
      end
      it "raises error for non-existent message id" do
        with_cassette :facebook, :delete_bogus_message do
          expect{subject.delete_message("999987359688716_108211673019999")}.to \
            raise_error(SocialMedia::Error) { |error| expect(error.wrapped_exception).to be_a Koala::Facebook::ClientError }
        end
      end
    end

    describe "Profile" do
      context "no page_name provided" do
        its(:connection_params) { is_expected.to_not include :page_name }
        it "can upload a profile cover image" do
          with_cassette :facebook, :upload_profile_cover do
            expect{subject.upload_profile_cover chrome_image_path}.to \
              raise_error SocialMedia::Error::NotProvided, "SocialMedia::Service::Facebook#upload_profile_cover"
          end
        end

        it "can remove a profile cover image" do
          with_cassette :facebook, :remove_profile_cover do
            expect{subject.remove_profile_cover}.to \
              raise_error SocialMedia::Error::NotProvided, "SocialMedia::Service::Facebook#remove_profile_cover"
          end
        end

        it "can upload a profile avatar image" do
          with_cassette :facebook, :upload_profile_avatar do
            expect{subject.upload_profile_avatar chrome_image_path}.to \
              raise_error SocialMedia::Error::NotProvided, "SocialMedia::Service::Facebook#upload_profile_avatar"
          end
        end

        it "can remove a profile avatar image" do
          expect{subject.remove_profile_avatar}.to \
            raise_error SocialMedia::Error::NotProvided, "SocialMedia::Service::Facebook#remove_profile_avatar"
        end
      end

      context "page_name provided" do
        let(:params) { service_configurations[described_class.name].merge!(page_name: page_name) }
        its(:connection_params) { is_expected.to include :page_name }

        it "can upload a profile cover image" do
          with_cassette :facebook, :upload_profile_cover do
            expect{subject.upload_profile_cover wallpaper_image_path}.to_not raise_error
          end
        end

        it "can remove a profile cover image" do
          with_cassette :facebook, :remove_profile_cover do
            expect{subject.remove_profile_cover}.to_not raise_error
          end
        end

        it "can upload a profile avatar image" do
          with_cassette :facebook, :upload_profile_avatar do
            expect{subject.upload_profile_avatar tux_image_path}.to_not raise_error
          end
        end

        it "can remove a profile avatar image" do
          pending "implement creating pages and uploading account/page image"
          with_cassette :facebook, :remove_profile_avatar do
            expect{subject.remove_profile_avatar}.to_not raise_error
          end
        end
      end
    end

  end
end
