ActiveAdmin.register ActsAsTaggableOn::Tag, as: "Tag" do
  permit_params :name

  controller do
    def find_resource
      ActsAsTaggableOn::Tag.find_by_name(URI::decode(params[:id]))
    end
  end


end
