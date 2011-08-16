/**
 * $Id: editor_plugin_src.js 520 2008-01-07 16:30:32Z spocke $
 *
 * @author Moxiecode
 * @copyright Copyright © 2004-2008, Moxiecode Systems AB, All rights reserved.
 */

(function() {
        // Load plugin specific language pack
        tinymce.PluginManager.requireLangPack('curblyadvimage');

        tinymce.create('tinymce.plugins.CurblyAdvancedImagePlugin', {
                init : function(ed, url) {
                        // Register commands
                        ed.addCommand('mceCurblyAdvImage', function() {
                                var e = ed.selection.getNode();

                                // Internal image object like a flash placeholder
                                if (ed.dom.getAttrib(e, 'class').indexOf('mceItem') != -1)
                                        return;

                                ed.windowManager.open({
                                        file : url + '/image.htm',
                                        width : 480 + parseInt(ed.getLang('curblyadvimage.delta_width', 0)),
                                        height : 385 + parseInt(ed.getLang('curblyadvimage.delta_height', 0)),
                                        inline : 1
                                }, {
                                        plugin_url : url
                                });
                        });

                        // Register buttons
                        ed.addButton('image', {
                                title : 'curblyadvimage.image_desc',
                                cmd : 'mceCurblyAdvImage'
                        });
                },

                getInfo : function() {
                        return {
                                longname : 'Curbly Advanced image',
                                author : 'Moxiecode Systems AB',
                                authorurl : 'http://tinymce.moxiecode.com',
                                infourl : 'http://wiki.moxiecode.com/index.php/TinyMCE:Plugins/advimage',
                                version : tinymce.majorVersion + "." + tinymce.minorVersion
                        };
                }
        });

        // Register plugin
        tinymce.PluginManager.add('curblyadvimage', tinymce.plugins.CurblyAdvancedImagePlugin);
})();