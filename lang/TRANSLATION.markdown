How translation works
=====================

Text which is visible to the user in CE is represented by translation tokens. Any text visible to users in your application should be represented by a translation token followed by a `.l` (e.g. `:this_phrase_needs_translation.l`). 

This tells the system to look for a translation of this phrase in the appropriate locale file. It will look for that in either `Rails.root/lang/ui` or `Rails.root/vendor/plugin/community_engine/lang/ui`, picking up a YAML-file which begins with the locale you've set in `application.yml` (e.g. `de-DE.yml`). 

Why load locales from both directories? The latter holds the standard translations that come with CE. The former is for your customized translation (use `Rails.root/vendor/plugin/community_engine/lang/en.yml` as a reference of all tokens used in CE).

If you see a token like `_translation_missing_` save the URL and the context of it and post a request at Lighthouse or the Google group to get it fixed.

For Developers
==============
If you rework standard CE and you add a visible item to a view (a UI element, a flash notice or something similar), please use the translation tokens to add text. Place these tokens in `en.yml` for other translators to give them a chance to complete their translation files.
NOTE: If you have special characters or a colon in your translation phrase you have to surround them with double quotes.

For Translators
===============
Try using the translate plugin: [http://github.com/bborn/translate](http://github.com/bborn/translate) when creating or updating translations in new locales

It provides you with some useful rake tasks, including:

    rake translate:diff_keys FROM_LOCAL=en TO_LOCALE=es 
    #Shows you which keys exist in FROM_LOCALE.yml but not in TO_LOCALE.yml
    
    rake translate:obsolete LOCALE=es
    #Shows you which keys exists in LOCALE.yml but not in the application source
    
    rake translate:orphans LOCALE=es
    #Show you which keys are in your template code but aren't in LOCALE.yml


