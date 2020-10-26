ActiveAdmin.register MetroArea do
  menu false
  permit_params :name, :state, :country_id, :state_id
end

