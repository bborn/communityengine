Technoweenie::AttachmentFu::InstanceMethods.module_eval do

  # Overriding this method to allow content_type to be detected when
  # swfupload submits images with content_type set to 'application/octet-stream'
  def uploaded_data=(file_data)
    return nil if file_data.nil? || file_data.size == 0
    self.content_type = detect_mimetype(file_data)
    self.filename     = file_data.original_filename if respond_to?(:filename)
    if file_data.is_a?(StringIO)
      file_data.rewind
      self.temp_data = file_data.read
    else
      self.temp_path = file_data.path
    end
  end
  
  def detect_mimetype(file_data)
    if file_data.content_type.strip == "application/octet-stream"
      return File.mime_type?(file_data.original_filename)
    else
      return file_data.content_type
    end
  end

  protected

  # Downcase and remove extra underscores from uploaded images
  def sanitize_filename(filename)
    returning filename.strip do |name|
      # NOTE: File.basename doesn't work right with Windows paths on Unix
      # get only the filename, not the whole path
      name.gsub! /^.*(\\|\/)/, ''
    
      # Finally, replace all non alphanumeric, underscore or periods with underscore
      name.gsub! /[^\w\.\-]/, '_'
    
      # Remove multiple underscores
      name.gsub!(/\_+/, '_')
  
      # Downcase result including extension
      name.downcase!
    end
  end
end


Technoweenie::AttachmentFu::Backends::FileSystemBackend.module_eval do
  # Force tests to use a temporary directory instead of the project's public directory
  def full_filename(thumbnail = nil)
    file_system_path = (thumbnail ? thumbnail_class : self).attachment_options[:path_prefix].to_s
    File.join(env_dir, file_system_path, *partitioned_path(thumbnail_name_for(thumbnail)))
  end

  # Use this to override the default directory when in test mode
  def env_dir
    RAILS_ENV == "test" ? Dir::tmpdir() : RAILS_ROOT
  end
end
