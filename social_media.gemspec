$:.push File.expand_path("../lib", __FILE__)

require "social_media/version"

Gem::Specification.new do |s|
  s.name        = "social_media"
  s.version     = SocialMedia::VERSION
  s.authors     = ["mwlang"]
  s.email       = ["mwlang@cybrains.net"]
  s.homepage    = "https://github.com/mwlang/social_media"
  s.summary     = "Social Media allows publishing to any number of social media services using one common API."
  s.description = "Social Media allows publishing to any number of social media services using one common API."
  s.license     = "MIT"

  s.files = Dir["{app,config,db,lib}/**/*", "MIT-LICENSE", "Rakefile", "README.md"]

  s.add_dependency "rails", "~> 5.0.1"
  s.add_dependency "twitter", "~> 6.0.0"
  s.add_dependency "koala", "~> 2.4"
  s.add_dependency "google-api-client", "~> 0.9"

  s.add_development_dependency "rspec", "~> 3.5.0"
  s.add_development_dependency "rspec-its", "~> 1.2.0"
  s.add_development_dependency "simplecov"
  s.add_development_dependency "guard"
  s.add_development_dependency "guard-rspec"
  s.add_development_dependency "vcr", "~> 2.9.3"
  s.add_development_dependency "webmock", "~> 1.21.0"
end
