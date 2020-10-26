ActiveAdmin.register Page do
  form do |f|
    tabs do
      tab 'Main' do
        f.semantic_errors *f.object.errors.keys
        inputs 'Details' do
          input :title
          input :published_as, as: :select, collection: ['live', 'draft']
          li "Created at #{f.object.created_at}" unless f.object.new_record?
        end

        inputs 'Content' do
          input :body, input_html: {class: 'rich_text_editor'}
        end
      end

    end

    panel 'Actions' do
      actions
    end
  end


end
