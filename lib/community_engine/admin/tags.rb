ActiveAdmin.register ActsAsTaggableOn::Tag, as: "Tag" do
  # menu :parent => "Taxonomy", :priority => 2
  menu false
  permit_params :name

  filter :name


  controller do
    def find_resource
      ActsAsTaggableOn::Tag.find_by_name(URI::decode(params[:id]))
    end
  end


  index do
    column :id
    column :name
    column :taggings_count
    column :featured
  end
end
