# Devise::Unpwn
Devise extension that checks user passwords against the PwnedPasswords dataset (https://haveibeenpwned.com/Passwords).

Checks for compromised ("pwned") passwords in 2 different places/ways:
1. As a standard model validation using [pwned](https://github.com/philnash/pwned). This:
   - prevents new users from being created (signing up) with a compromised password
   - prevents existing users from changing their password to a password that is known to be compromised
2. (Optionally) Whenever a user signs in, checks if their current password is compromised and shows a warning if it is.

Based on [devise-uncommon_password](https://github.com/HCLarsen/devise-uncommon_password).

Recently the HaveIBeenPwned API has moved to an [authenticated/paid model](https://www.troyhunt.com/authentication-and-the-have-i-been-pwned-api/), but this does not affect the PwnedPasswords API; no payment or authentication is required.

## Installation

```bash
bundle add devise-unpwn
```

## Usage
Add the `:unpwned` module to your existing Devise model.

```ruby
class AdminUser < ApplicationRecord
  devise :database_authenticatable,
         :recoverable, :rememberable, :trackable, :validatable, :unpwned
end
```

Users will receive the following error message if they use a password from the
PwnedPasswords dataset:

> Password has previously appeared in a data breach and should never be used. Please choose something harder to guess.

## Configuration

You can customize this error message by modifying the `devise` YAML file.

```yml
# config/locales/devise.en.yml
en:
  errors:
    messages:
      pwned_password: "has previously appeared in a data breach and should never be used. If you've ever used it anywhere before, change it immediately!"
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

By default responses from the PwnedPasswords API are timed out after 5 seconds
to reduce potential latency problems.
Optionally, you can add the following snippet to `config/initializers/devise.rb`
to control the timeout settings:

```ruby
config.unpwn_open_timeout = 1
config.unpwn_read_timeout = 2
```


### How to warn existing users when they sign in

You can optionally warn existing users when they sign in if they are using a password from the PwnedPasswords dataset.

To enable this, you _must_ override `after_sign_in_path_for`, like this:

```ruby
# app/controllers/application_controller.rb
  def after_sign_in_path_for(resource)
    set_flash_message! :alert, :warn_pwned if resource.respond_to?(:pwned?) && resource.pwned?
    super
  end
```

For an [Active Admin](https://github.com/activeadmin/activeadmin) application the following monkey patch is needed:

```ruby
# config/initializers/active_admin_devise_sessions_controller.rb
class ActiveAdmin::Devise::SessionsController
  def after_sign_in_path_for(resource)
    set_flash_message! :alert, :warn_pwned if resource.respond_to?(:pwned?) && resource.pwned?
    super
  end
end
```

To prevent the default call to the HaveIBeenPwned API on user sign-in (only
really useful if you're going to check `pwned?` after sign-in as used above),
add the following to `config/initializers/devise.rb`:

```ruby
config.pwned_password_check_on_sign_in = false
```

#### Customize warning message

The default message is:
```
Your password has previously appeared in a data breach and should never be used. We strongly recommend you change your password.
```

You can customize this message by modifying the `devise.en.yml` locale file.

```yml
# config/locales/devise.en.yml
en:
  devise:
    sessions:
      warn_pwned: "Your password has previously appeared in a data breach and should never be used. We strongly recommend you change your password everywhere you have used it."
```

#### Customize the warning threshold

By default the same value, `config.min_password_matches` is used as the threshold for rejecting a passwords for _new_ user sign-ups and for warning existing users.

If you want to use different thresholds for rejecting the password and warning
the user (for example you may only want to reject passwords that are common but
warn if the password occurs at all in the list), you can set a different value for each.

To change the threshold used for the warning _only_, add to `config/initializers/devise.rb`

```ruby
# Minimum number of times a pwned password must exist in the data set in order
# to warn the user.
config.min_password_matches_warn = 1
```

Note: If you do have a different warning threshold, that threshold will also be used
when a user changes their password (added as an _error_!) so that they don't
continue to be warned if they choose another password that is in the pwned list
but occurs with a frequency below the main threshold that is used for *new*
user registrations (`config.min_password_matches`).

### Disabling in test environments

Currently this module cannot be mocked out for test environments. Because an API call is made this can slow down tests, or make test fixtures needlessly complex (dynamically generated passwords). The module can be disabled in test environments like this.

```ruby
class User < ApplicationRecord
  devise :invitable ...  :validatable, :lockable
  devise :pwned_password unless Rails.env.test?
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

* This puts an external API in the request path of users signing up to your application. This could
  potentially add some latency to this operation. The gem is designed to silently swallows errors if
  the PwnedPasswords service is unavailable, allowing users to use compromised passwords during the
  time when it is unavailable.

## Attribution

Originally based on [devise-pwned_password](https://github.com/michaelbanfield/devise-pwned_password).

## Development

After checking out the repo, run `bin/setup` to install dependencies. Then, run `bin/test` to run the tests. To release a new version, push a new version tag to GitHub by running `bin/rake bump [major|minor|patch]` and then `bin/rake tag`.

## Contributing

Bug reports and pull requests are welcome on GitHub at https://github.com/indirect/devise-unpwn. This project is intended to be a safe, welcoming space for collaboration, and contributors are expected to adhere to the [code of conduct](https://github.com/indirect/devise-unpwn/blob/main/CODE_OF_CONDUCT.md).

## Code of Conduct

Everyone interacting in the Devise::Unpwn project's codebases, issue trackers, chat rooms and mailing lists is expected to follow the [code of conduct](https://github.com/indirect/devise-unpwn/blob/main/CODE_OF_CONDUCT.md).
