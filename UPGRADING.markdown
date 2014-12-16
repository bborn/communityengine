Upgrading to v3.0.0
===================
* Follow the various guides for converting from Rails 3.x to Rails 4
* Run `bundle exec rake app:community_engine:install:migrations`
* Run `rake db:migrate`
* Run `rake test && take community_engine:test`

Some things may not be compatible; some of the views and forms have changed.

Upgrading to v1.2.1
===================
* Run `ruby script/generate plugin_migration`
* Run `rake db:migrate`
* Run `rake test && rake community_engine:test`


Upgrading to v1.2.0
===================
* Run `ruby script/generate plugin_migration`
* Run `rake db:migrate`
* Run `rake test && rake community_engine:test`

To migrate existing private messages to the new threaded message format, run `rake community_engine:add_threads_to_existing_messages` on your production server (CAREFUL: make backups first!)


Upgrading to v1.1.0
=====================
* Run `ruby script/generate plugin_migration`
* Run `rake db:migrate`
* Run `rake test && rake community_engine:test`


Upgrading to v1.0.4.2
=====================
* Run `rake gems:install`
* Run `ruby script/generate plugin_migration`
* Run `rake db:migrate`
* Run `rake test && rake community_engine:test`

That's it!

Note: this version adds a counter_cache to taggings, so you may need to update the counter on your existing tags by doing something like:

```ruby
ActsAsTaggableOn::Tag.all.each do |tag|
        tag.update_counters tag.id, :taggings_count => tag.taggings.length
end
```

If you have many tags, this could take a while.

Upgrading to v1.0.4
===================
* Run `ruby script/generate plugin_migration`.
* Make sure you have the following in your `environment.rb`:

  ```
  config.gem 'authlogic'
  config.gem 'icalendar'
  config.gem 'calendar_date_select'
  ```

* Run `rake db:migrate`

That's it!



Upgrading v1.0.2
================

Beginning with CE v.1.0.2, we have started using the Desert gem instead of the Engines plugin. Desert does many of the things the Engines plugin did, but also allows model code mixing. Also, in light of Engine's inclusion into Rails core, it appeared many of the features CE loves about Engines (plugin migrations, asset helpers, code mixing) were going to be dropped.

Upgrading an Engines-based CE app to use the new Desert-based CE is easy:

1. Modify your environment.rb as indicated in **step #6** of README.markdown.

2. Delete the engines plugin directory (`rm -rf vendor/plugins/engines`). If you had submoduled it, make sure to delete the submodule info as well:

  * Delete the relevant line from the `.gitmodules` file
  * Delete the relevant section from `.git/config`
  * Run `git rm --cached vendor/plugins/engines` (no trailing slash)
  * Run `rm -rf vendor/plugins/engines`
  * Commit your changes


2. Run `rake:rails:update` (coming from anything < Rails 2.3)

3. Update your app's `test_helper.rb`, replacing `Test::Unit::TestCase` with `ActiveSupport::TestCase`

4. Run `rake test` && `rake community_engine:test`



Notes
=====
If you have old migrations from the Engines-based CE, you may experience some problems if you try to migrate your db from version 0. That's because the old plugin migrations used the `Engines.plugins["community_engine"].migrate(version_number)` format. You'll need to replace all those with `migrate_plugin(:community_engine, version_number)`.

Here's a regex that might help you in doing that:

Find:

```
(Engines|Rails)\.plugins\[\"community_engine\"\]\.migrate\(([0-9]+)\)
```

Replace:

```
migrate_plugin(:community_engine, $2)`
```

Also, you need to run `rake community_engine:db:migrate:upgrade_desert_plugin_migrations` before you migrate any _new_ CE migrations, to ensure your plugin migrations are listed in the correct table. Please note that you'll have to do this (carefully, and with backups) in production as well. Please post any questions to the CE Google Group.
