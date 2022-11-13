# frozen_string_literal: true

$:.push File.expand_path("../lib", __FILE__)

# Maintain your gem's version:
require "devise/pwned_password/version"

# Describe your gem and declare its dependencies:
Gem::Specification.new do |s|
  s.name = "devise-pwned_password"
  s.version = Devise::PwnedPassword::VERSION
  s.authors = ["Michael Banfield"]
  s.email = ["michael@michaelbanfield.com"]
  s.homepage = "https://github.com/michaelbanfield/devise-pwned_password"
  s.summary = "Devise extension that checks user passwords against the PwnedPasswords dataset."
  s.description = "Devise extension that checks user passwords against the PwnedPasswords dataset https://haveibeenpwned.com/Passwords."
  s.license = "MIT"

  s.files = Dir["{app,config,db,lib}/**/*", "MIT-LICENSE", "Rakefile", "README.md"]

  s.add_dependency "devise", "~> 4"
end
