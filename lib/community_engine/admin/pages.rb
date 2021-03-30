ActiveAdmin.register Page do
  permit_params :title, :body, :published_as

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
          input :body, input_html: {:style => "width:95%;", :class => "codemirror"}
        end
      end

    end

    panel 'Actions' do
      actions
    end
  end


end
