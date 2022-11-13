# frozen_string_literal: true

require "devise"
require "devise/unpwn/model"

module Devise
  mattr_accessor :min_password_matches, :unpwn_open_timeout, :unpwn_read_timeout
  @@min_password_matches = 1
  @@unpwn_open_timeout = 5
  @@unpwn_read_timeout = 5

  module Unpwn
  end
end

# Load default I18n
#
I18n.load_path.unshift File.join(File.dirname(__FILE__), *%w[unpwn locales en.yml])

Devise.add_module :unpwn, model: "devise/unpwn/model"
