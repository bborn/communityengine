ActiveAdmin.register Post do
  permit_params :title, :raw_post, :published_at, :published_as, :category_id

  filter :user
  filter :published_as
  filter :published_at
  filter :created_at



  index do
    selectable_column
    column :id
    column :user
    column :title
    column :created_at
    column :updated_at
    column :published_at
    column :published_as

    actions
  end

  form do |f|
    tabs do
      tab 'Main' do
        f.semantic_errors *f.object.errors.keys
        inputs 'Details' do
          input :title
          input :published_at, as: :datepicker, label: "Publish Post At"
          input :published_as, as: :select, collection: [['Live', 'live'], ['Draft', 'draft']]
          li "Created at #{f.object.created_at}" unless f.object.new_record?
          input :category
        end

        inputs 'Content' do
          input :raw_post, input_html: {class: 'rich_text_editor'}
        end
      end

      tab 'Meta' do
      end

    end

    panel 'Actions' do
      actions
    end
  end



end
