class ThemeController < BaseController
  def stylesheets
    render_theme_item(:stylesheets, params[:filename], 'text/css; charset=utf-8')
  end

  def javascript
    render_theme_item(:javascript, params[:filename], 'text/javascript; charset=utf-8')
  end

  def images
    render_theme_item(:images, params[:filename])
  end

  def error
    render :nothing => true, :status => 404
  end

  private

  def render_theme_item(type, file, mime = nil)

    mime ||= mime_for(file)
    if file.split(%r{[\\/]}).include?("..")
      return (render :text => "Not Found", :status => 404)
    end

    src = "#{Rails.root}/themes/#{configatron.theme}" + "/#{type}/#{file}"
    return (render :text => "Not Found", :status => 404) unless File.exists? src

    if perform_caching
      dst = "#{page_cache_directory}/#{type}/theme/#{file}"
      FileUtils.makedirs(File.dirname(dst))
      FileUtils.cp(src, "#{dst}.#{$$}")
      FileUtils.ln("#{dst}.#{$$}", dst) rescue nil
      FileUtils.rm("#{dst}.#{$$}", :force => true)
    end
    send_file(src, :type => mime, :disposition => 'inline', :stream => true)
  end

  def mime_for(filename)
    case filename && filename.downcase
    when /\.js$/
      'text/javascript'
    when /\.css$/
      'text/css'
    when /\.gif$/
      'image/gif'
    when /(\.jpg|\.jpeg)$/
      'image/jpeg'
    when /\.png$/
      'image/png'
    when /\.swf$/
      'application/x-shockwave-flash'
    else
      'application/binary'
    end
  end


end