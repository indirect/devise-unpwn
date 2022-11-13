module Factories
  def create_user(password:)
    User.new(
      email: "example@example.org",
      password: password,
      password_confirmation: password
    ).tap do |user|
      user.save(validate: false)
      user.password_confirmation = user.password = user.password
      # user.valid? && puts(%(user.errors.messages=#{(user.errors.messages).inspect}))
    end
  end

  def pwned_password
    "password"
  end

  def pwned_password_user
    create_user(password: pwned_password)
  end

  def valid_password
    "fddkasnsdddghjt"
  end

  def valid_password_user
    user = create_user(password: valid_password)
    assert_equal 0, user.errors.size
    user
  end
end

class ActiveSupport::TestCase
  include Factories
end
