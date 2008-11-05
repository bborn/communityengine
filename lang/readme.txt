How translation works
=====================

Translation in CE is organised by translation tokens, which means where ever in your apps (controllers, helpers, views etc.) all stuff visible to users is represented by a token followed by a ".l" (e.g. :this_phrase_needs_translation.l ). This "hints" the system to look for a translation of this phrase. It will look for that in either RAILS_ROOT/lang/ui or RAILS_ROOT/vendor/plugin/community_engine/lang/ui for a YAML-file which begins with the locale you've set in application.yml (e.g. de-DE.yml). Why looking into different dirs? The latter one is the standard dir which comes with CE. The former one is for your customised translation (use RAILS_ROOT/vendor/plugin/community_engine/lang/base.yml as a reference of all tokens used in standard CE).

Pages like FAQ, About or bigger hints and tips are not translation because we expect that the majority of CE users will change them anyway.

If you see a token like "_translation_missing_" save the URL and the context of it and post a request at lighthouse or google group to get it fixed.

For Developers
==============
If you rework standard CE and you add a visible item to a view, a flash notice or something else, please use strictly the translation tokens. Place these tokens in base.yml for other translators to give them a chance to complete their translation files.

Keep in mind: if you have special characters or a colon in your translation phrase you have to surround them with double quotes.