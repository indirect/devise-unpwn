# frozen_string_literal: true

require "test_helper"

class Devise::Unpwn::Test < ActiveSupport::TestCase
  class WhenPwned < Devise::Unpwn::Test
    test "should deny validation and set pwned?" do
      user = pwned_password_user
      assert_not user.valid?
      assert_match(/\Ahas appeared in a data breach\z/, user.errors[:password].first)
      assert user.pwned?
    end
  end

  class WhenNotPwned < Devise::Unpwn::Test
    test "should accept validation and set pwned_count" do
      user = valid_password_user
      assert user.valid?
      assert_equal user.pwned?, false
    end

    test "when password changed to a pwned password: should add error" do
      user = valid_password_user
      password = "password"
      user.update password: password, password_confirmation: password
      assert_not user.valid?
      assert user.pwned?
    end
  end
end
