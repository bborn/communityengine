ActiveAdmin.register Category do
  permit_params :name, :tips, :new_post_text, :nav_text, :slug
end
