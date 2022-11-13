$:.push File.expand_path("../lib", __FILE__)
require "devise/unpwn/version"

Gem::Specification.new do |s|
  s.name = "devise-unpwn"
  s.version = Devise::Unpwn::VERSION
  s.authors = ["André Arko"]
  s.email = ["andre@arko.net"]
  s.homepage = "https://github.com/indirect/devise-unpwn"
  s.summary = "Block pwned passwords for Devise users"
  s.description = "Devise extension that checks user passwords against the HaveIBeenPwned dataset."
  s.license = "MIT"

  s.files = Dir["{app,config,db,lib}/**/*", "MIT-LICENSE", "Rakefile", "README.md"]

  s.add_dependency "devise", "~> 4"
end
