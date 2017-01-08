module FixtureHelper
  def image_fixture_path base_name, kind="png"
    file_path = File.expand_path(File.join(File.dirname(__FILE__), '..'))
    File.join file_path, "fixtures", "images", kind.to_s, "#{base_name}.#{kind}"
  end

  def image_fixture base_name, kind="png"
    File.read image_fixture_path base_name, kind
  end
end

RSpec.configure do |config|
  include FixtureHelper
end
