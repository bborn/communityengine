ActiveAdmin.register Post do
  permit_params :title, :post, :raw_post, :user_id, :published_at, :published_as


  form do |f|
    tabs do
      tab 'Main' do
        f.semantic_errors *f.object.errors.keys
        inputs 'Details' do
          input :title
          input :published_at, as: :datepicker, label: "Publish Post At"
          input :published_as, as: :select, collection: ['live', 'draft']
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
