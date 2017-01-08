module VcrHelper
  def with_cassette service, name
    VCR.use_cassette("#{service}/#{name}", record: :new_episodes) do
      yield
    end
  end
end

RSpec.configure do |config|
  include VcrHelper
end
