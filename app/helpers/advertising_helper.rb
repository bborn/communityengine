module AdvertisingHelper
  IS_DEVELOPMENT = RAILS_ENV.eql?('development')
  CHANNELS = {:cat_landing_leaderboard => "0060845024",
    :cat_landing_sidebar => "4264875008",
    :popular_leaderboard => "3135993241",
    :popular_sidebar => "2423599612",
    :show_post_leaderboard => "2844965600",
    :show_post_sidebar => "2556042165",    
    :show_blog_sidebar => "1011432825",
    :tags_show_sidebar => "5380455944",
    :tags_show_leaderboard => "8498235296",
    :user_list_sidebar => "4433795796"
    }

  AD_FORMATS = {
    '250x250_as' => {:google_ad_width => '250',
      :google_ad_height => '250',
      :google_ad_format => "250x250_as",
      :google_ad_type => "text_image"
    },
    '728x90_as' => {
      :google_ad_width => '728',
      :google_ad_height => '90',
      :google_ad_format => "728x90_as",
      :google_ad_type => "text_image"
    }  
  }


  def adbrite_ad_unit
    code = <<-EOF
    <!-- Begin: AdBrite -->
    <script type="text/javascript">
       var AdBrite_Title_Color = '1EA2C1';
       var AdBrite_Text_Color = '333333';
       var AdBrite_Background_Color = 'FFFFFF';
       var AdBrite_Border_Color = 'FFFFFF';
    </script>
    <script src="http://ads.adbrite.com/mb/text_group.php?sid=235500&zs=3330305f323530" type="text/javascript"></script>
    <div><a target="_top" href="http://www.adbrite.com/mb/commerce/purchase_form.php?opid=235500&afsid=1" style="font-weight:bold;font-family:Arial;font-size:13px;">Your Ad Here</a></div>
    <!-- End: AdBrite -->
    EOF
    code
  end

  def google_ad_unit(ad_format, channel)
    return "Ads turned off for development" if IS_DEVELOPMENT
    merged_options = {
      :google_ad_client => "pub-9113954708528841",
      :google_alternate_color => "FFFFFF",
      :google_color_border => "FFFFFF",
      :google_color_bg => "FFFFFF",
      :google_color_link => "1EA2C1",
      :google_color_text => "333333",
      :google_color_url => "666666"
    }.merge(ad_format)
    
    code = "<script type=\"text/javascript\"><!--\n"
    merged_options.each do |k,v| 
      code += k.to_s + " = '" + v.to_s + "';\n"
    end  
    code += <<-EOF
      #{'google_ad_channel = "'+ channel +'";' unless IS_DEVELOPMENT}
      #{'google_adtest = "on";' if IS_DEVELOPMENT}      
      //--></script>
      <script type="text/javascript"
        src="http://pagead2.googlesyndication.com/pagead/show_ads.js">
      </script>
    EOF
    code
  end

end