require 'spec_helper'

RSpec.describe SocialMedia::Service::Facebook do
  context "class methods" do
    subject { described_class }
    its(:name) { is_expected.to eq :facebook }
  end

  if service_configured? described_class.name
    let(:service) { described_class.new service_configurations[described_class.name] }
    subject { service }

    it "instantiates" do
      expect(subject).to be_a SocialMedia::Service::Facebook
    end
    its(:connection_params) { is_expected.to include :app_key }
    its(:connection_params) { is_expected.to include :app_secret }
  end
end
