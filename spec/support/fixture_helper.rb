module FixtureHelper
  def image_fixture_path base_name, kind="png"
    file_path = File.expand_path(File.join(File.dirname(__FILE__), '..'))
    File.join file_path, "fixtures", "images", kind.to_s, "#{base_name}.#{kind}"
  end

  def image_fixture base_name, kind="png"
    File.open image_fixture_path base_name, kind
  end
end

RSpec.configure do |config|
  include FixtureHelper
end

RSpec.shared_context "shared_image_fixtures" do
  let(:chrome_image_path)     { image_fixture_path(:chrome, :png) }
  let(:firefox_image_path)    { image_fixture_path(:firefox, :png) }
  let(:ie_image_path)         { image_fixture_path(:ie, :png) }
  let(:opera_image_path)      { image_fixture_path(:ie, :png) }
  let(:netscape_image_path)   { image_fixture_path(:netscape, :png) }
  let(:wallpaper_image_path)  { image_fixture_path(:wallpaper, :jpg) }

  let(:chrome_image)          { image_fixture(:chrome, :png) }
  let(:firefox_image)         { image_fixture(:firefox, :png) }
  let(:ie_image)              { image_fixture(:ie, :png) }
  let(:opera_image)           { image_fixture(:ie, :png) }
  let(:netscape_image)        { image_fixture(:netscape, :png) }
  let(:wallpaper_image)       { image_fixture(:wallpaper, :jpg) }
end
