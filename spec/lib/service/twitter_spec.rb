require 'spec_helper'

RSpec.describe SocialMedia::Service::Twitter do
  context "class methods" do
    subject { described_class }
    its(:name) { is_expected.to eq :twitter }
  end

  if service_configured? described_class.name
    let(:service) { described_class.new service_configurations[described_class.name] }
    subject { service }

    it "instantiates" do
      expect(subject).to be_a SocialMedia::Service::Twitter
    end
    its(:connection_params) { is_expected.to include :consumer_key }
    its(:connection_params) { is_expected.to include :consumer_secret }
    its(:connection_params) { is_expected.to include :access_token }
    its(:connection_params) { is_expected.to include :access_token_secret }
  end

  context "invalid token error" do
    let(:service) { described_class.new service_configurations[described_class.name] }
    before { service.connection_params[:access_token] = 'bogus' }
    subject { service }

    it "wraps the twitter specific error" do
      with_cassette :twitter, :invalid_token do
        expect{subject.send_message("This is a test")}.to raise_error SocialMedia::Error, "Twitter::Error::Unauthorized: Invalid or expired token."
      end
    end
  end

  describe "sending a text message" do
    it "can send a message" do
      with_cassette :twitter, :send_text do
        expect(subject.send_message("This is a test")).to eq 818202062479572993
      end
    end
  end

  describe "sending a message with images" do
    it "can send a message with one image" do
      pending "not implemented"
      expect(:pending).to eq :completed
    end

    it "can send a message with multiple images" do
      pending "not implemented"
      expect(:pending).to eq :completed
    end
  end

  describe "deleting a message" do
    it "can delete a message" do
      with_cassette :twitter, :delete_test do
        expect(subject.delete_message(818202062479572993)).to eq 818202062479572993
      end
    end
  end

  describe "Profile" do
    it "can upload a profile background image" do
      with_cassette :twitter, :upload_profile_background do
        expect(subject.update_profile_background image_fixture_path(:wallpaper, :jpg)).to eq true
      end
    end

    it "can update a profile image" do
      with_cassette :twitter, :upload_profile_image do
        expect(subject.update_profile_image image_fixture_path(:logo, :png)).to eq 806014044222189568
      end
    end
  end
end
