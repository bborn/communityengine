ActiveAdmin.register User do
  permit_params :avatar_id, :country_id, :description, :email,
                 :gender, :login, :metro_area_id,
                 :notify_comments, :notify_community_news,
                 :notify_friend_requests, :password, :password_confirmation,
                 :profile_public, :state_id, :stylesheet, :vendor, :zip,
                 :tag_list,
                 {:avatar_attributes => [:id, :name, :description, :album_id, :user, :user_id, :photo, :photo_remote_url]}, :birthday


  index do
    selectable_column
    column :id
    column :login
    column :email
    column :created_at
    actions
  end


  form do |f|
    f.semantic_errors *f.object.errors.keys

    inputs 'Details',  :email, :login, :password, :password_confirmation

    inputs 'Description' do
      input :description, input_html: {class: 'rich_text_editor'}
      input :tag_list
      input :gender
      input :birthday
    end

    f.inputs 'Location', :country, :state, :metro_area, :zip

    f.inputs 'Notifications',  :notify_comments, :notify_community_news, :notify_friend_requests

    f.actions
  end


  # def activate_user
  #   user = User.find(params[:id])
  #   user.activate
  #   flash[:notice] = :the_user_was_activated.l
  #   redirect_to :action => :users
  # end

  # def deactivate_user
  #   user = User.find(params[:id])
  #   user.deactivate
  #   flash[:notice] = :the_user_was_deactivated.l
  #   redirect_to :action => :users
  # end
end
