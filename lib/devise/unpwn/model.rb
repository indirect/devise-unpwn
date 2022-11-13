# frozen_string_literal: true

require "unpwn"
require "devise/unpwn/hooks/unpwn"

module Devise
  module Models
    # The Unpwn module adds a new validation for Devise Models.
    # No modifications to routes or controllers needed.
    # Simply add :unpwned to the list of included modules in your
    # devise module, and all new registrations will be blocked if they use
    # a password in this dataset https://haveibeenpwned.com/Passwords.
    module Unpwned
      extend ActiveSupport::Concern

      included do
        validate :not_pwned_password, if: :will_save_change_to_encrypted_password?
      end

      module ClassMethods
        Devise::Models.config(self, :unpwn_check_on_sign_in)
        Devise::Models.config(self, :unpwn_request_options)
      end

      # Lets us show a message after Warden checks the password during login
      def pwned?
        @pwned ||= false
      end

      # Returns true if password is found in the Unpwn dataset or HaveIBeenPwned API
      def password_pwned?(password)
        request_options = {
          headers: {"User-Agent" => "devise-unpwn"}
        }.merge(self.class.unpwn_request_options)

        @pwned = Unpwn.new(request_options: request_options).pwned?(password)
      end

      private

      def not_pwned_password
        errors.add(:password, :pwned_password) if password_pwned?(password)
      end
    end
  end
end
