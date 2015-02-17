ActiveAdmin.register Forum do
  permit_params :name, :description, :position, :description_html
end
