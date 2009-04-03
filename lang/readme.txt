How translation works
=====================

Translation in CE is organized by translation tokens, which any text visible to users in your application should be represented by a translation token followed by a ".l" (e.g. :this_phrase_needs_translation.l). 

This tells the system to look for a translation of this phrase in the appropriate locale file. It will look for that in either RAILS_ROOT/lang/ui or RAILS_ROOT/vendor/plugin/community_engine/lang/ui, picking up a YAML-file which begins with the locale you've set in application.yml (e.g. de-DE.yml). Why load locales from both directories? The latter holds the standard translation that come with CE. The former one is for your customized translation (use RAILS_ROOT/vendor/plugin/community_engine/lang/base.yml as a reference of all tokens used in standard CE).

Pages like FAQ, About and others are not translation because we expect that the majority of CE users override those views anyway.

If you see a token like "_translation_missing_" save the URL and the context of it and post a request at Lighthouse or the Google group to get it fixed.

For Developers
==============
If you rework standard CE and you add a visible item to a view (a UI element, a flash notice or something similar), please use the translation tokens to add text. Place these tokens in base.yml for other translators to give them a chance to complete their translation files.

NOTE: if you have special characters or a colon in your translation phrase you have to surround them with double quotes.