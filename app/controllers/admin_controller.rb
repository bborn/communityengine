class AdminController < BaseController
  before_action :admin_required

  # def clear_cache
  #   case Rails.cache
  #     when ActiveSupport::Cache::FileStore
  #       dir = Rails.cache.cache_path
  #       unless dir == Rails.public_path
  #         FileUtils.rm_r(Dir.glob(dir+"/*")) rescue Errno::ENOENT
  #         Rails.logger.info("Cache directory fully swept.")
  #       end
  #       flash[:notice] = :cache_cleared.l
  #     else
  #       Rails.logger.warn("Cache not swept: you must override AdminController#clear_cache to support #{Rails.cache}")
  #   end
  #   redirect_to admin_dashboard_path and return
  # end


  # def comments
  #   @search = Comment.search(params[:q])
  #   @comments = @search.result.distinct
  #   @comments = @comments.order("created_at DESC").page(params[:page]).per(100)
  # end

end
