require 'spec_helper'

RSpec.describe SocialMedia::Service::Instagram do
  context "class methods" do
    subject { described_class }
    its(:name) { is_expected.to eq :instagram }
  end

  if service_configured? described_class.name
    let(:service) { described_class.new service_configurations[described_class.name] }
    subject { service }

    it "instantiates" do
      expect(subject).to be_a SocialMedia::Service::Instagram
    end
    its(:connection_params) { is_expected.to include :app_key }
    its(:connection_params) { is_expected.to include :app_secret }

    context "invalid token error" do
      let(:service) { described_class.new service_configurations[described_class.name] }
      before { service.connection_params[:user_access_token] = 'bogus' }
      subject { service }

      it "wraps the LinkedIn specific error" do
        with_cassette :instagram, :invalid_token do
          expect{subject.send_message("This is a test")}.to raise_error SocialMedia::Error, "TODO: fix"
        end
      end
    end

    describe "sending a text message" do
      it "can send a message" do
        with_cassette :instagram, :send_text do
          expect(subject.send_message("This is a test")).to eq 'fixme'
        end
      end
    end

    describe "sending a message with images" do
      it "can send a message with one image" do
        with_cassette :instagram, :send_image do
          expect(subject.send_message("Testing image upload", filename: chrome_image_path)).to eq 'fixme'
        end
      end

      it "can send a message with multiple images" do
        filenames = [chrome_image_path, firefox_image_path, ie_image_path]
        with_cassette :instagram, :send_images do
          expect(subject.send_message("Testing multiple image uploads", filenames: filenames)).to eq 'fixme'
        end
      end
    end

    describe "deleting a message" do
      it "can delete a message" do
        with_cassette :instagram, :delete_test do
          expect(subject.delete_message('fixme')).to eq 'fixme'
        end
      end
    end

    describe "Profile" do
      it "can upload a profile cover image" do
        with_cassette :instagram, :upload_profile_cover do
          expect(subject.upload_profile_cover wallpaper_image_path).to eq true
        end
      end

      it "can remove a profile cover image" do
        with_cassette :instagram, :remove_profile_cover do
          expect(subject.remove_profile_cover).to eq true
        end
      end

      it "can upload a profile avatar image" do
        with_cassette :instagram, :upload_profile_avatar do
          expect(subject.upload_profile_avatar chrome_image_path).to eq 'fixme'
        end
      end

      it "can remove a profile avatar image" do
        expect{subject.remove_profile_avatar}.to \
          raise_error SocialMedia::Error::NotProvided, "SocialMedia::Service::GooglePlus#remove_profile_avatar"
      end
    end

    describe "NotProvided behavior" do
      let(:config) { service_configurations[described_class.name].merge!(not_provided_behavior: behavior) }
      let(:service) { described_class.new config }

      context ":raise_error" do
        let(:behavior) { :raise_error }

        it "raises an error" do
          expect{subject.remove_profile_avatar}.to \
            raise_error SocialMedia::Error::NotProvided, "SocialMedia::Service::GooglePlus#remove_profile_avatar"
        end
      end

      context ":silent" do
        let(:behavior) { :silent }

        it "does not raise an error" do
          expect{subject.remove_profile_avatar}.to_not raise_error
        end
      end
    end
  end
end
