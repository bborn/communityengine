ActiveAdmin.register_page 'Dashboard' do
  controller do
    before_action do |_|
      redirect_to admin_master_classes_path
    end
  end
end

# ActiveAdmin.register_page "Dashboard" do

#   menu priority: 1, label: proc{ I18n.t("active_admin.dashboard") }

#   page_action :clear_cache do
#     case Rails.cache
#       when ActiveSupport::Cache::FileStore
#         dir = Rails.cache.cache_path
#         unless dir == Rails.public_path
#           FileUtils.rm_r(Dir.glob(dir+"/*")) rescue Errno::ENOENT
#           Rails.logger.info("Cache directory fully swept.")
#         end
#         flash[:notice] = :cache_cleared.l
#       else
#         Rails.logger.warn("Cache not swept: you must override AdminController#clear_cache to support #{Rails.cache}")
#     end
#     redirect_to admin_dashboard_path and return
#   end


#   content title: proc{ I18n.t("active_admin.dashboard") } do

#     columns do
#       column do
#         panel "Info" do
#           para "Welcome to CE."
#         end
#       end

#       column do
#         panel "Cache" do
#           link_to "Clear cache", admin_dashboard_clear_cache_path
#         end
#       end
#     end

#     end # content
#   end
