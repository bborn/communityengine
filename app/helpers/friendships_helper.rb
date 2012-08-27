module FriendshipsHelper

  def friendship_control_links(friendship)
    html = case friendship.friendship_status_id
      when FriendshipStatus[:pending].id
        "#{(link_to(:accept.l, accept_user_friendship_path(friendship.user, friendship), :method => :put, :class => 'btn btn-mini btn-success') unless friendship.initiator?)} #{link_to(:deny.l, deny_user_friendship_path(friendship.user, friendship), :method => :put, :class => 'btn btn-mini btn-danger')}"
      when FriendshipStatus[:accepted].id
        "#{link_to(:remove_this_friend.l, deny_user_friendship_path(friendship.user, friendship), :method => :put, :class => 'btn btn-mini btn-danger')}"
      when FriendshipStatus[:denied].id
    		"#{link_to(:accept_this_request.l, accept_user_friendship_path(friendship.user, friendship), :method => :put, :class => 'btn btn-mini btn-success')}"
    end
    
    html.html_safe
  end

end
