# frozen_string_literal: true

require "devise"
require "devise/unpwn/model"

module Devise
  mattr_accessor :unpwn_check_on_sign_in, :unpwn_request_options
  @@unpwn_request_options = {}
  @@unpwn_check_on_sign_in = true

  module Unpwn
  end
end

# Load default I18n
#
I18n.load_path.unshift File.join(File.dirname(__FILE__), *%w[unpwn locales en.yml])

Devise.add_module :unpwn, model: "devise/unpwn/model"
