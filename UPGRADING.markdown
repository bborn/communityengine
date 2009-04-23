Upgrading from CE v1.0.0 to v1.0.2 (desert)
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
