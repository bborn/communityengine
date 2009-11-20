Upgrading to v1.0.4.2
=====================
Run `rake gems:install`
Run `ruby script/generate plugin_migration`
Run `rake db:migrate`
Run `rake test && rake community_engine:test`
That's it!


Upgrading to v1.0.4
===================
Run `ruby script/generate plugin_migration`
Make sure you have the following in your `environment.rb`:

        config.gem 'authlogic'
        config.gem 'icalendar'
        config.gem 'calendar_date_select'
        
Run `rake db:migrate`
That's it!



Upgrading v1.0.2
================

Beginning with CE v.1.0.2, we have started using the Desert gem instead of the Engines plugin. Desert does many of the things the Engines plugin did, but also allows model code mixing. Also, in light of Engine's inclusion into Rails core, it appeared many of the features CE loves about Engines (plugin migrations, asset helpers, code mixing) were going to be dropped. 

Upgrading an Engines-based CE app to use the new Desert-based CE is easy:

1. Modify your environment.rb as indicated in **step #6** of README.markdown.

2. Delete the engines plugin directory (`rm -rf vendor/plugins/engines`). If you had submoduled it, make sure to delete the submodule info as well:

        Delete the relevant line from the .gitmodules file.
        Delete the relevant section from .git/config.
        Run git rm --cached vendor/plugins/engines (no trailing slash).
        Run rm -rf vendor/plugins/engines
        Commit your changes
        

2. run `rake:rails:update` (coming from anything < Rails 2.3)

3. Update your app's `test_helper.rb`, replacing `Test::Unit::TestCase` with `ActiveSupport::TestCase`

4. `rake test` && `rake community_engine:test`



Notes
=====
If you have old migrations from the Engines-based CE, you may experience some problems if you try to migrate your db from version 0. That's because the old plugin migrations used the `Engines.plugins["community_engine"].migrate(version_number)` format. You'll need to replace all those with `migrate_plugin(:community_engine, version_number)`.

Also, you need to run `rake community_engine:db:migrate:upgrade_desert_plugin_migrations` before you migrate any _new_ CE migrations, to ensure your plugin migrations are listed in the correct table. Please note that you'll have to do this (carefully, and with backups) in production as well. Please post any questions to the CE Google Group.