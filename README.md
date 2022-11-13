# Devise::Unpwn
Devise extension that checks user passwords against the HaveIBeenPwned dataset https://haveibeenpwned.com/Passwords


## Usage
Add the :unpwned module to your existing Devise model.

```ruby
class AdminUser < ApplicationRecord
  devise :database_authenticatable, 
         :recoverable, :rememberable, :trackable, :validatable, :unpwned
end
```

Users will receive the following error message if they use a password from the
HaveIBeenPwned dataset:

> Password has previously appeared in a data breach and should never be used. Please choose something harder to guess.

You can customize this error message by modifying the `devise` YAML file.

```yml
# config/locales/devise.en.yml
en:
  errors:
    messages:
      pwned_password: "has previously appeared in a data breach and should never be used. If you've ever used it anywhere before, change it immediately!"
```

You can optionally warn existing users when they sign in if they are using a password from the HaveIBeenPwned dataset. The default message is:

> Your password has previously appeared in a data breach and should never be used. We strongly recommend you change your password.

You can customize this message by modifying the `devise` YAML file.

```yml
# config/locales/devise.en.yml
en:
  devise:
    sessions:
      warn_pwned: "Your password has previously appeared in a data breach and should never be used. We strongly recommend you change your password everywhere you have used it."
```

By default passwords are rejected if they appear at all in the data set.
Optionally, you can add the following snippet to `config/initializers/devise.rb`
if you want the error message to be displayed only when the password is present
a certain number of times in the data set:

```ruby
# Minimum number of times a pwned password must exist in the data set in order
# to be reject.
config.min_password_matches = 10
```

By default responses from the HaveIBeenPwned API are timed out after 5 seconds
to reduce potential latency problems.
Optionally, you can add the following snippet to `config/initializers/devise.rb`
to control the timeout settings:

```ruby
config.unpwn_open_timeout = 1
config.unpwn_read_timeout = 2
```

## Installation

```bash
bundle add devise-unpwn
```

Optionally, if you also want to warn existing users when they sign in, override `after_sign_in_path_for`
```ruby
def after_sign_in_path_for(resource)
  set_flash_message! :alert, :warn_pwned if resource.respond_to?(:pwned?) && resource.pwned?
  super
end
```

This should generally be added in `app/controllers/application_controller.rb` for a rails app. For an Active Admin application the following monkey patch is needed.

```ruby
# config/initializers/active_admin_devise_sessions_controller.rb
class ActiveAdmin::Devise::SessionsController
  def after_sign_in_path_for(resource)
    set_flash_message! :alert, :warn_pwned if resource.respond_to?(:pwned?) && resource.pwned?
    super
  end
end
```


## Considerations

A few things to consider/understand when using this gem:

* User passwords are hashed using SHA-1 and then truncated to 5 characters,
  implementing the k-Anonymity model described in
  https://haveibeenpwned.com/API/v2#SearchingPwnedPasswordsByRange
  Neither the clear-text password nor the full password hash is ever transmitted
  to a third party. More implementation details and important caveats can be
  found in https://blog.cloudflare.com/validating-leaked-passwords-with-k-anonymity/

* This puts an external API in the request path of users signing up to your
  application. This could potentially add some latency to this operation. The
  gem is designed to fail silently if the HaveIBeenPwned service is unavailable.

## Attribution

Originally based on [devise-pwned_password](https://github.com/michaelbanfield/devise-pwned_password).

## Development

After checking out the repo, run `bin/setup` to install dependencies. Then, run `bin/test` to run the tests. To release a new version, push a new version tag to GitHub by running `bin/rake bump [major|minor|patch]` and then `bin/rake tag`.

## Contributing

Bug reports and pull requests are welcome on GitHub at https://github.com/indirect/devise-unpwn. This project is intended to be a safe, welcoming space for collaboration, and contributors are expected to adhere to the [code of conduct](https://github.com/indirect/devise-unpwn/blob/main/CODE_OF_CONDUCT.md).

## Code of Conduct

Everyone interacting in the Devise::Unpwn project's codebases, issue trackers, chat rooms and mailing lists is expected to follow the [code of conduct](https://github.com/indirect/devise-unpwn/blob/main/CODE_OF_CONDUCT.md).
