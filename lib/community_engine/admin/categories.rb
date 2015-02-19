ActiveAdmin.register Category do
  permit_params :name, :tips, :new_post_text, :nav_text, :slug

  menu :parent => "Taxonomy", :priority => 1
  filter :name

  index do
    column :id do |category|
      link_to category.id, admin_category_path(category)
    end

    column :name
    column :tips
    column :posts do |category|
      category.posts.count
    end
    default_actions
  end

end
