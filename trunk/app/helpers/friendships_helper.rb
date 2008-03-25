module FriendshipsHelper

  def friendship_control_links(friendship)
    case friendship.friendship_status_id
      when FriendshipStatus[:pending].id
    		content_tag 'h3', "#{(link_to("Accept", accept_user_friendship_path(friendship.user, friendship), :method => :put) unless friendship.initiator?)} or #{link_to( 'Deny', deny_user_friendship_path(friendship.user, friendship), :method => :put)}"
      when FriendshipStatus[:accepted].id
    		content_tag 'h3', "#{link_to("Remove this friendship", deny_user_friendship_path(friendship.user, friendship), :method => :put)}"
      when FriendshipStatus[:denied].id
    		content_tag 'h3', "#{link_to("Accept this friendship", accept_user_friendship_path(friendship.user, friendship), :method => :put)}"        
    end
  end

end
