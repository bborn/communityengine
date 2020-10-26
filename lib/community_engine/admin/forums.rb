ActiveAdmin.register Forum do
  menu false
  permit_params :name, :description, :position, :description_html
end
