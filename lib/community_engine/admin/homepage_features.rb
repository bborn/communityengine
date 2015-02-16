ActiveAdmin.register HomepageFeature, as: "Features" do
  permit_params :url, :title, :description, :image

  form do |f|

    f.semantic_errors *f.object.errors.keys
    inputs 'Details' do
      input :url
      input :title
    end

    inputs 'Content' do
      input :description, input_html: {class: 'rich_text_editor'}
      input :image, as: :file, required: true, hint: image_tag(f.object.image.url(:thumb))
    end


    panel 'Actions' do
      actions
    end
  end



end
