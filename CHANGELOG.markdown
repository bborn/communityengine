# Changelog

## 3.0.0

* Upgraded to Bootstrap 3

  *t-bullock*

* Upgraded to Font Awesome 4

  *t-bullock*

* Upgraded to Configatron 4

  *t-bullock*

* Various bug fixes

## 3.0.0.pre3

* Merged in the jquery-bootstrap branch

* Removed old prototype.js code

## 3.0.0.pre2

* Upgraded to TinyMCE 4.0.2; made fix to mce_options to make it work.

  *Polar Humenn*

* Removed curblyadvimage from tinymce plugins (not working)

  *Polar Humenn*

* Made fix for Users params when nothing is modified.

  *Polar Humenn*

## 3.0.0.pre1

* Moved forms and links to unobtrusive javascript. Still using Prototype.

  *Polar Humenn*

* Addressed almost all 4.0/4.1 deprecation issues

  *Polar Humenn*

* Migrated to ActiveRecord Query syntax.

  *Polar Humenn*

* Replaced `:method => :put` with `:method => :patch`

  *Polar Humenn*

* Removed `attr_accessible` and `attr_protected` in favor of StrongParameters

  *Polar Humenn*

* Replaced some 2.3 style plugins with bona fide gems, removed, or moved to lib
  * activity_tracker          ---> lib
  * acts_as_list              ---> gem acts_as_list
  * acts_as_commentable       ---> gem acts_as_commentable, `requires db:migrate`
  * acts_as_publishable       ---> lib
  * auto_complete             ---> lib
  * bborn-acts-as-taggable-on ---> gem acts_as_taggable-on
  * enumerations_mixin        ---> gem power_num
  * prototype_legacy_helper   ---> lib  (about to be removed)
  * resource_feeder           ---> lib
  * responds_to_parent        ---> removed
  * white_list                ---> lib

  *Polar Humenn*

* Replaced or Upgraded gems
  * `gem ransak`       replaces       `gem meta_search`
  * `gem friendly_id`  upgrade requires a `db:migrate` and syntactical changes

  *Polar Humenn*

* Added gems as per directions supporting caching in Rails 4
  * actionpack-action_caching
  * actionpack-page_caching
  * rails-observers

  *Polar Humenn*

## 2.3.1

* Remove automatic loading of omniauth middleware, in favor of letting users load it themselves as specified in the README
  * This was causing bugs with duplicate inits of omniauth-facebook middleware

* Add spam comment moderation

  * Comments identified as spam as held in 'pending status'

## 2.3.0

* Upgrade omniauth to 1.1

## 2.0.0.beta4

* Replace white_list plugin with Sanitize gem (white_list.rb initizlizer format has changed)

* Upgrade to Rails 3.2

* Use act_as_taggable_on

* Fix photo cropping

* Remove theme controller (no more theming functionality)

## 2.0.0.pre

* Rails 3.1.0.beta1 compatibility

## 1.9.9

* Rails 3.1 compatibility

* Ruby 1.9.2 compatibility

* Use Paperclip instead of attachment_fu

* Add Omniauth

* Remove lots of old, unused featured (contests, skills, offerings, etc.)

## 1.2.1

* Anonymous forum replies

* Turn comment notifications on or off by post

* Allow admins/mods to edit comments (they can already delete them)

* Fix security vulnerability in AuthenticatedSystem

## 1.2.0

* Threaded private messages

* Clear cache link in admin dashboard

* Add support for using rakismet gem to check comments for spam (see README for instructions)

## 1.1.0

* Fixed time_ago formatting problem on user/index

* User Authlogic's perishable token for doing password resets (instead of sending them a password)

## 1.0.4.2

* Rails 2.3.4 compatibility (all tests pass)

  *Takk*

* Add searchlogic gem dependency
  * searchlogic is awesome, will be using it more in the future, currently just using on `admin_controller#comments`

* Add searchlogic to manage tags page, add taggings_count to tags (new migration)

## 1.0.4

* Changes to Japanese language translations

* Use authlogic instead of restful_authentication.
  * Augthlogic gem now required, new migrations required

  *jnimety*

* Big overhaul of i18n, more international-friendly translation tokens. `en` is now the default locale (instead of `en-US`)

  *sdecleire*

## 1.0.3

* Complete private messages integration, allow sending messages to multiple recipients

* Upgrades to Event functionality, including RSVPs

  *eksatx*

* Photo albums, Static pages and messages controller tests

  *juafrlo*, *eksatx*

* calendar_date_select, icalendar gems now required

* Added ability to unsubscribe from comment notifications for anonymous comments

* ical format output for Events to allow subscriptions

## 1.0.2

* Rails 2.3 compatibility

* RedCloth no longer required

* Fixed swfupload to work with 2.3 and use Rack middleware

* Use Desert plugin for code mixing and plugin migrations instead of Engines

* Allow moderators/activity owners to delete activities

* Only track login activity once per day

* Allow anonymous commenters to choose whether they want to receive follow-up comment notices by e-mail

* Refactor views to use 'box' helper for logical content modules, allowing better flexibility when trying to customize layouts

## 1.0.1

* Fixed error when cropping photos using file system storage

* Fixed error on `messages#delete`

## 1.0.0

* Postgres compatibility

  *Johannes*

* Some SEO improvements to page titles and urls for showing tags

* Fixed a security vulnerability

* Updated to newest attachment_fu plugin
  * Note new cropping in geometry strings for photo in application.yml
  * This attachment fu requires ImageMagick 6.4 or greater

* Updated swfupload to fix flash 10 compatibility

* Added ability to crop profile photo to better fit dimensions (/username/crop_profile_photo)

* Updated TinyMCE scripts

* Updated to newest Prototype and scriptaculous, and removed unused javascript files

## 0.10.8

* Updating CE for Rails 2.2.2 compatibility

* Removed Globalite in favor of Rails' native I18n API. Ce localization should work without modification

* Renamed dozens of files to use Rails 2.0 conventions (ie. .html.haml)

* Updated truncate calls to use new options hash format

## 0.10.7

* Updating CE to be compatible with Rails 2.1.2

* Lots of il8n refactoring, mainly using symbol tokens instead of string for localization in views.
