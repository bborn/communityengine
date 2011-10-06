CommunityEngine [v1.2.1]
** Looking for the Rails 3.1 version? You want the [Rails3 branch](https://github.com/bborn/communityengine/tree/rails3).

CommunityEngine [v1.0.4.2]

Information at: [http://www.communityengine.org](http://www.communityengine.org)

Requirements:

	- RAILS VERSION 2.3.4 (higher versions are not yet supported)
	- ImageMagick (>6.4) 
	- Several gems:
    desert 0.5.2
	  rmagick
	  hpricot
	  htmlentities
	  rake 0.8.3
	  haml 2.0.5
	  calendar_date_select
	  ri_cal
    authlogic
    searchlogic
    rakismet
	  aws-s3 (if using s3 for photos)

Getting CommunityEngine Running
--------------------------------

SHORT VERSION: 

        rails your_app_name -m https://raw.github.com/bborn/communityengine/edge/community_engine_setup_template.rb

LONG VERSION:

1. From the command line

		$ rails site_name (create a rails app if you don't have one already)    

2. Install desert:

		$ sudo gem install desert
	
3. Put the community engine plugin into plugins directory (use one of the following methods):

	* If you're not using git, and just want to add the source files:

			Download a tarball from https://github.com/bborn/communityengine/tarball/master and unpack it into /vendor/plugins/community\_engine

	* Using git, make a shallow clone of the community_engine repository:

			$ git clone --depth 1 git://github.com/bborn/communityengine.git vendor/plugins/community_engine

	* If you want to keep your community_engine plugin up to date using git, you'll have to add it as a submodule:
	
			http://www.kernel.org/pub/software/scm/git/docs/user-manual.html#submodules
			Basically:
			git submodule add git://github.com/bborn/communityengine.git vendor/plugins/community_engine
			git submodule init
			git submodule update

	* Make sure you rename your CE directory to `community_engine` (note the underscore) if it isn't named that for some reason

4. Create your database and modify your `config/database.yml` appropriately.

5. Delete public/index.html (if you haven't already)

6. Modify your environment.rb as indicated below:

		## environment.rb should look something like this:
		RAILS_GEM_VERSION = '2.3.4' unless defined? RAILS_GEM_VERSION
		require File.join(File.dirname(__FILE__), 'boot')

        require 'desert'

		Rails::Initializer.run do |config|
		  config.plugins = [:community_engine, :white_list, :all]
		  config.plugin_paths += ["#{RAILS_ROOT}/vendor/plugins/community_engine/plugins"]
		  config.gem 'calendar_date_select'
		  config.gem 'icalendar'		
		  config.gem 'authlogic'
		  config.gem 'searchlogic'
		  config.gem 'rakismet'		  
		  
      config.action_controller.session = {
        :key    => '_your_app_session',
        :secret => 'secret'
      }

		  ... Your stuff here ...
		end
		# Include your application configuration below
		require "#{RAILS_ROOT}/vendor/plugins/community_engine/config/boot.rb"

7. Modify each environment file (`development.rb`, `test.rb`, and `production.rb`) as indicated below:

		# development.rb, production.rb, and test.rb should include something like:
		APP_URL = "http://localhost:3000" (or whatever your URL will be for that particular environment)

8. Modify your routes.rb as indicated below:

		# Add this after any of your own existing routes, but before the default rails routes: 
		map.routes_from_plugin :community_engine
		# Install the default routes as the lowest priority.
		map.connect ':controller/:action/:id'
		map.connect ':controller/:action/:id.:format'     

9. Generate the community engine migrations: 

		$ script/generate plugin_migration
    
10. From the command line:
	
		$ rake db:migrate

11. You may need to change these lines in `application.rb` (if you're not using cookie sessions):

		# See ActionController::RequestForgeryProtection for details
		# Uncomment the :secret if you're not using the cookie session store
		protect_from_forgery # :secret => 'your_secret_string'

12. Run tests (remember, you must run `rake test` before you can run the community\_engine tests): 

    $ rake test
		$ rake community_engine:test

13. Start your server and check out your site! 

		$ mongrel_rails start
		or
		$ ./script/server



Optional Configuration
======================


To override the default configuration, create an `application.yml` file in `RAILS_ROOT/config` 

The application configuration defined in this file overrides the one defined in `/community_engine/config/application.yml`

This is where you can change commonly used configuration variables, like `AppConfig.community_name`, etc.

This YAML file will get converted into an OpenStruct, giving you things like `AppConfig.community_name`, `AppConfig.support_email`, etc.

Photo Uploading
---------------

By default CommunityEngine uses the filesystem to store photos.

To use Amazon S3 as the backend for your file uploads, you'll need the aws-s3 gem installed, and you'll need to add a file called `amazon_s3.yml` to the application's root config directory (examples are in `/community_engine/sample_files`). 

You'll need to change your configuration in your `application.yml` to tell CommunityEngine to use s3 as the photo backend.

Finally, you'll need an S3 account for S3 photo uploading.


Create an s3.yml file in `RAILS_ROOT/config` 
------------------------------------------------------

CommunityEngine includes the `s3.rake` tasks for backing up your site to S3. If you plan on using these, you'll need to add a file in `RAILS_ROOT/config/s3.yml`. (Sample in `sample_files/s3.yml`)

Roles
------

CommunityEngine Users have a Role (by default, it's admin, moderator, or member)

To set a user as an admin, you must manually change his `role_id` through the database.
Once logged in as an admin, you'll be able to toggle other users between moderator and member (just go to their profile page and look on the sidebar.)

Admins and moderators can edit and delete other users posts.

There is a rake task to make an existing user into an admin: 

	rake community_engine:make_admin email=user@foo.com 

(Pass in the e-mail of the user you'd like to make an admin)


Themes
------

To create a theme:

1. Add a 'themes' directory in `RAILS_ROOT` with the following structure:

		/RAILS_ROOT
		  /themes
		    /your_theme_name
		      /views
		      /images
		      /stylesheets
		      /javascripts
      
2. Add `theme: your_theme_name` to your `application.yml` (you'll have to restart your server after doing this)

3. Customize your theme. For example: you can create a `/RAILS_ROOT/theme/your_theme_name/views/shared/_scripts_and_styles.html.haml` to override the default one, and pull in your theme's styleshees.

	To get at the stylesheets (or images, or javascripts) from your theme, just add /theme/ when referencing the resource, for example:

		= stylesheet_link_tag 'theme/screen'  # this will reference the screen.css stylesheet within the selected theme's stylesheets directory.

*Note: when running in production mode, theme assets (images, js, and stylesheets) are automatically copied to you public directory (avoiding a Rails request on each image load).*


Localization
------------

Localization is done via Rails native I18n API. We've added some extensions to String and Symbol to allow backwards compatibility (we used to use Globalite).

Strings and Symbols respond to the `.l` method that allows for a look up of the symbol (or a symbolized version of the string) into a strings file which is stored in yaml. 

For complex strings with substitutions, Symbols respond to the `.l` method with a hash passed as an argument, for example: 

	:welcome.l :name => current_user.name
  
And in your language file you'd have:

	welcome: "Welcome {{name}}"

To customize the language, or add a new language create a new yaml file in `RAILS_ROOT/lang/ui`.
The name of the file should be `LANG-LOCALE.yml` (`e.g. en-US.yml` or `es-PR`)
The language only file (`es.yml`) will support all locales.

To wrap all localized strings in a `<span>` that shows their localization key, put this in your `environment.rb`:

	AppConfig.show_localization_keys_for_debugging = true if RAILS_ENV.eql?('development')
  
Note, this will affect the look and feel of buttons. You can highlight what is localized by using the `span.localized` style (look in `screen.css`)

For more, see /lang/readme.txt.


Spam Control
------------

Spam sucks. Most likely, you'll need to implement some custom solution to control spam on your site, but CE offers a few tools to help with the basics. 

ReCaptcha: to allow non-logged-in commenting and use [ReCaptcha](http://recaptcha.net/) to ensure robots aren't submitting comments to your site, just add the following lines to your `application.yml`:

    allow_anonymous_commenting: true
    recaptcha_pub_key: YOUR_PUBLIC_KEY
    recaptcha_priv_key: YOUR_PRIVATE_KEY
    
You can also require recaptcha on signup (to prevent automated signups) by adding this in your `application.yml` (you'll still need to add your ReCaptcha keys):

    require_captcha_on_signup: true
    
Akismet: Unfortunately, bots aren't the only ones submitting spam; humans do it to. [Akismet](http://akismet.com/) is a great collaborative spam filter from the makers of Wordpress, and you can use it to check for spam comments by adding one line to your `application.yml`:

    akismet_key: 4bfd15b0ea46
  
(If you do this, make sure you are requiring the `rakismet` gem in `environment.rb`)
    


Other notes
-----------

Any views you create in your app directory will override those in `community_engine/app/views`. 
For example, you could create `RAILS_ROOT/app/views/layouts/application.html.haml` and have that include your own stylesheets, etc.

You can also override CommunityEngine's controllers by creating identically-named controllers in your application's `app/controllers` directory.


Gotchas
-------

1. I get errors running rake! Error: (wrong number of arguments (3 for 1)
  - make sure you have the latest version of rake
2. When upgrading to Rails 2.3, make sure your `action_controller.session` key is called `:key`, instead of the old `:session_key`:

        config.action_controller.session = {
          :key => '_ce_session',
          :secret      => 'secret'
        }


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


To Do
----
* Track down `<RangeError ... is recycled object>` warnings on tests (anyone know where that's coming from?)

Bug tracking is via [Lighthouse](http://communityengine.lighthouseapp.com)
