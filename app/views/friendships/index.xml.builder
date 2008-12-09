xml.instruct!
xml.RelationViewerData do 
  xml.Settings :appTitle=>"#{AppConfig.community_name} Friendships Browser", :WWWLinkTargetFrame=>"_blank", :startID=>"#{APP_URL}/#{@user.login_slug}", 
    :defaultRadius=>"170", :maxRadius=>"240", :contextRadius=>"130" do 
    xml.RelationTypes do 
      xml.DirectedRelation :color=>"0x999999", :lineSize=>"3"
    end
    xml.NodeTypes do 
      xml.Person
    end
  end
  
  xml.Nodes do
    @users.each do |user|
      imageUrl = (user.avatar_photo_url(:thumb).eql?('icon_missing_thumb.png') ? '/images/icon_missing_thumb.png' : user.avatar_photo_url(:thumb) )
      xml.Person :tags => "#{user.tags.collect{|t| t.name }.join(", ")}", :dataURL=>"friendships.xml?id=#{user.id}", 
      :id=>"#{APP_URL}/#{user.login_slug}", :name=>"#{user.login}", :imageURL=>imageUrl, :URL=>"#{APP_URL}/#{user.login_slug}" do
          xml.cdata!( truncate_words( strip_tags(user.description), 50, '...') )
      end
    end
  end
  
  xml.Relations do 
    @friendships.each do |friendship|
      xml.DirectedRelation :fromID=>"#{APP_URL}/#{friendship.user.login_slug}", :toID=>"#{APP_URL}/#{friendship.friend.login_slug}"
    end
  end

end