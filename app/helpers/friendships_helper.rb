module FriendshipsHelper

  def friendship_control_links(friendship)
    case friendship.friendship_status_id
      when FriendshipStatus[:pending].id
        "#{(link_to("Accept", accept_user_friendship_path(friendship.user, friendship), :method => :put, :class => 'button positive') unless friendship.initiator?)} #{link_to( 'Deny', deny_user_friendship_path(friendship.user, friendship), :method => :put, :class => 'button negative')}"
      when FriendshipStatus[:accepted].id
        "#{link_to("Remove this friend", deny_user_friendship_path(friendship.user, friendship), :method => :put, :class => 'button negative')}"
      when FriendshipStatus[:denied].id
    		"#{link_to("Accept this request", accept_user_friendship_path(friendship.user, friendship), :method => :put, :class => 'button positive')}"
    end
  end

end
