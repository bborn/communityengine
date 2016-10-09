CommunityEngine
===============

[![Build Status](https://travis-ci.org/bborn/communityengine.svg?branch=edge)](https://travis-ci.org/bborn/communityengine)
[![Dependency Status](https://img.shields.io/gemnasium/bborn/communityengine.svg?style=flat)](https://gemnasium.com/bborn/communityengine)
[![Code Climate](https://img.shields.io/codeclimate/github/bborn/communityengine.svg?style=flat)](https://codeclimate.com/github/bborn/communityengine)
[![Gem Version](https://img.shields.io/gem/v/community_engine.svg?style=flat)](https://rubygems.org/gems/community_engine)

Travis for taro-k account  
[![Build Status](https://travis-ci.org/taro-k/communityengine.svg?branch=edge)](https://travis-ci.org/taro-k/communityengine)

Information at: [http://www.communityengine.org](http://www.communityengine.org)

**Requirements:**

	- RAILS VERSION 4.2
	- RUBY  2.0.x

For Rails 2.x use the [rails2.x branch](https://github.com/bborn/communityengine/tree/rails2.x)

For Rails 3.x use the [rails3.x branch](https://github.com/bborn/communityengine/tree/rails3.x)

For Rails 4.0 use the [rails4.0 branch](https://github.com/bborn/communityengine/tree/rails4.0)

For Rails 4.1 use the [master branch](https://github.com/bborn/communityengine)


Getting CommunityEngine Running
--------------------------------

1. Copy the following into your `Gemfile`:

  ```ruby
  gem 'community_engine', :github => 'bborn/communityengine', :branch => "edge"
  ```

2. Add a file called `application_config.rb` to your `config` directory. In it put (at least):

  ```ruby
  configatron.community_name = "Your Application Name"
  # See CE's application_config.rb to see all the other configuration options available
  ```

3. From your app's root directory run:

  ```
  $ bundle install --binstubs
  $ bin/rake community_engine:install:migrations
  $ bin/rake db:migrate
  ```

4. Mount CommunityEngine in your `config/routes.rb` file:

  ```ruby
  mount CommunityEngine::Engine => "/"
  ```

5. Delete the default `views/layouts/application.html.erb` that Rails created for you. Delete `public/index.html` if you haven't already.

6. Start your server!

  ```
  $ bin/rails server
  ```

Alternative installation
------------------------

For a user with difficulty. Try
https://github.com/taro-k/ce_base

Optional Configuration
----------------------

To override the default configuration, create an `application_config.rb` file in `Rails.root/config`.

The application configuration defined in this file overrides the one defined in the [CommunityEngine gem](https://github.com/bborn/communityengine/blob/master/config/application_config.rb).

This is where you can change commonly used configuration variables, like `configatron.community_name`, etc.


OmniAuth Configuration
----------------------

You can allow users to sign up and log in using their accounts from other social networks (like Facbeook, Twitter, LinkedIn, etc.). To do so, just add an initializer in your app's `config/initializers` directory called `omniauth.rb` and add the following lines:

```ruby
Rails.application.config.middleware.use OmniAuth::Builder do
  provider :twitter, configatron.auth_providers.twitter.key, configatron.auth_providers.twitter.secret
  provider :facebook, configatron.auth_providers.facebook.key, configatron.auth_providers.facebook.secret, {:provider_ignores_state => true}
end
```

You must also add the corresponding provider gem, for example to use facebook login you will need to add the following to your gemfile:

```ruby
gem 'omniauth-facebook'
```

See the [OmniAuth Github repository](https://github.com/intridea/omniauth) for more information and configuration options.


Photo Uploading
---------------

By default CommunityEngine uses the filesystem to store photos.

To use Amazon S3 as the backend for your file uploads, you'll need to add a file called `s3.yml` to the application's root config directory (examples are in `/community_engine/sample_files`).

You'll need to change your configuration in your `application_config.rb` to tell CommunityEngine to use s3 as the photo backend. For more, see the Paperclip documentation on S3 storage for uploads: https://github.com/thoughtbot/paperclip/blob/master/lib/paperclip/storage/s3.rb.

Finally, you'll need an S3 account for S3 photo uploading.


Roles
------

CommunityEngine Users have a Role (by default, it's admin, moderator, or member).

Once logged in as an admin, you'll be able to toggle other users between moderator and member (just go to their profile page and look on the sidebar).

Admins and moderators can edit and delete other users posts.

There is a rake task to make an existing user into an admin:

```
$ rake community_engine:make_admin email=user@foo.com
```

(Pass in the e-mail of the user you'd like to make an admin)



Localization
------------

Localization is done via Rails native I18n API. We've added some extensions to String and Symbol to let them respond to the `.l` method. That allows for a look up of the symbol (or a symbolized version of the string).

For complex strings with substitutions, Symbols respond to the `.l` method with a hash passed as an argument, for example:

```ruby
:welcome.l :name => current_user.name
```

And in your language file you'd have:

```yaml
welcome: "Welcome %{name}"
```

To customize the language, or add a new language create a new yaml file in `Rails.root/config/locales`. The name of the file should be `LANG-LOCALE.yml` (`e.g. en-US.yml` or `es-PR`). The language only file (`es.yml`) will support all locales.


Spam Control
------------

Spam sucks. Most likely, you'll need to implement some custom solution to control spam on your site, but CE offers a few tools to help with the basics.

ReCaptcha: to allow non-logged-in commenting and use [ReCaptcha](http://recaptcha.net/) to ensure robots aren't submitting comments to your site, just add the following lines to your `application_config.rb`:

```ruby
:allow_anonymous_commenting => true,
:recaptcha_pub_key => YOUR_PUBLIC_KEY,
:recaptcha_priv_key => YOUR_PRIVATE_KEY
```

You can also require ReCaptcha on signup (to prevent automated signups) by adding this in your `application_config.rb` (you'll still need to add your ReCaptcha keys):

```ruby
:require_captcha_on_signup => true
```

Akismet: Unfortunately, bots aren't the only ones submitting spam; humans do it too. [Akismet](http://akismet.com/) is a great collaborative spam filter from the makers of Wordpress, and you can use it to check for spam comments by adding one line to your `application_config.rb`:

```ruby
:akismet_key => YOUR_KEY
```


Ads
------------

Ads are snippets of HTML that will be inserted into your templates. You have to declare where they show up in your view. For example, if you wanted a sidebar ad slot, add ```Ad.display()``` in your application template (or wherever your sidebar is):

```ruby
#sidebar
  %h1 This is the sidebar

  =Ad.display(:sidebar, logged_in?)
```

Then on the admin dashboard, create an ad and use "sidebar" as the location to target it to the :sidebar slot. You can create multiple ads for the same slot and they'll rotate according to their weight.


Integrating with Your Application & Overriding CE
-------------------------------------------------

To make a controller from your application use CE's layout and inherit CE's helper methods, make it inherit from `BaseController`. For example:

```ruby
class RecipesController < BaseController

	before_action :login_required

end
```

To override or modify a controller, helper, or model from CE, you can use the `require_from_ce` helper method. For example, to override a method in CE's `User` model, create `app/models/user.rb`:

```ruby
class User < ActiveRecord::Base
	require_from_ce('models/user')

	#add a new association
	has_many :recipes

	#override an existing method
	def	display_name
		login.capitalize
	end

end
```



Other Notes
-----------

Any views you create in your app directory will override those in CommunityEngine. For example, you could create `Rails.root/app/views/layouts/application.html.haml` and have that include your own stylesheets, etc.


Contributors - Thanks! :)
-------------------------

- Bryan Kearney - localization
- Alex Nesbitt - forgot password bugs
- Alejandro Raiczyk - Spanish localization
- [Fritz Thielemann](http://github.com/fritzek) - German localization, il8n
- [Oleg Ivanov](http://github.com/morhekil) - `acts_as_taggable_on_steroids`
- David Fugere - French localization
- Barry Paul - routes refactoring
- [Andrei Erdoss](http://github.com/cauta) localization
- [Errol Siegel](http://github.com/eksatx) simple private messages integration, documentation help
- Carl Fyffe - documentation, misc.
- [Juan de Frías](http://github.com/juafrlo) static pages, photo albums, message_controller tests
- [Joel Nimety](http://github.com/jnimety) authlogic authentication
- [Stephane Decleire](http://github.com/sdecleire) i18n, fr-FR locale
- [Polar Humenn](http://github.com/polar) Rails 4 port, and other slight improvements



Bug tracking is via [GitHub Issues](https://github.com/bborn/communityengine/issues)
