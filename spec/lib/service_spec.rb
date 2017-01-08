require 'spec_helper'

RSpec.describe SocialMedia::Service do
  subject { described_class }
  its(:services) { is_expected.to include(:facebook, :twitter, :linkedin) }

  context "service by name" do
    its(:twitter) { is_expected.to eq SocialMedia::Service::Twitter }
    its(:facebook) { is_expected.to eq SocialMedia::Service::Facebook }

    it "finds service by name" do
      expect(subject.service(:twitter)).to eq SocialMedia::Service::Twitter
    end

    it "returns nil for bogus service" do
      expect(subject.service(:bogus)).to be nil
    end

    it "returns service using it's name" do
      expect{subject.bogus}.to raise_error NoMethodError
    end
  end
end

RSpec.describe SocialMedia::Service::Base do
  subject { described_class }

  it "should raise error on name method" do
    expect{subject::name}.to raise_error NotImplementedError, "SocialMedia::Service::Base::name not implemented"
  end
end
