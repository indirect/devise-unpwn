# frozen_string_literal: true

$:.push File.expand_path("../lib", __FILE__)

# Maintain your gem's version:
require "devise/unpwn/version"

# Describe your gem and declare its dependencies:
Gem::Specification.new do |s|
  s.name = "devise-unpwn"
  s.version = Devise::Unpwn::VERSION
  s.authors = ["André Arko"]
  s.email = ["andre@arko.net"]
  s.homepage = "https://github.com/indirect/devise-unpwn"
  s.summary = "Devise extension that checks user passwords against the HaveIBeenPwned dataset."
  s.description = "Devise extension that checks user passwords against the HaveIBeenPwned dataset."
  s.license = "MIT"

  s.files = Dir["{app,config,db,lib}/**/*", "MIT-LICENSE", "Rakefile", "README.md"]

  s.add_dependency "devise", "~> 4"
end
