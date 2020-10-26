ActiveAdmin.register Ad do
  menu false
  permit_params :name, :html, :frequency, :audience, :start_date, :end_date, :location, :published, :time_constrained
end
