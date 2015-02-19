ActiveAdmin.register Post do
  permit_params :title, :raw_post, :published_at, :published_as, :category_id

  filter :title
  filter :user
  filter :published_as, as: :select, collection: [['Published','live'], ['Draft','draft']], include_blank: true
  filter :published_at
  filter :created_at

  scope_to do
    current_user
  end

  index do
    selectable_column
    column :id do |post|
      link_to post.id, admin_post_path(post)
    end

    column :published_at
    column :published_as do |post|
      if post.is_live? && post.published_at <= Time.now
        link_to(:published.l, user_post_path(post.user, post))
      elsif post.is_live? && post.published_at > Time.now
        "Pending"
      elsif !post.is_live?
        :draft.l
      end
    end

    column :title do |post|
      link_to post.title, user_post_path(post.user, post)
    end
    column :tags do |post|
      simple_format post.taggings.group_by(&:context).map{|context, array|
           "<strong>#{context}</strong>: " + array.map{|t| t.tag.name }.join(',')
        }.join("\n")
    end

    actions
  end

  form do |f|
    tabs do
      tab 'Content' do
        f.semantic_errors *f.object.errors.keys
        inputs 'Title' do
          input :title
        end

        inputs 'Content' do
          input :raw_post, input_html: {class: 'rich_text_editor'}
        end
      end

      tab 'Meta' do
        inputs 'Publishing' do
          input :published_at, minute_step: 15
          input :published_as, as: :select, collection: [['Live', 'live'], ['Draft', 'draft']]
          li "Created at #{f.object.created_at}" unless f.object.new_record?
        end

        inputs "Taxonomy" do
          input :category
          input :tag_list, input_html: {id: 'tags', data: {auto_complete_url: auto_complete_for_tag_name_tags_path}}
        end

        inputs 'Commenting' do
          input :comments_disabled
          input :send_comment_notifications
        end
      end

    end

    panel 'Actions' do
      actions
    end
  end



end
