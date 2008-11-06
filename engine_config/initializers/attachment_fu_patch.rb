require 'tempfile'
class Tempfile
  # Returns the size of the temporary file.  As a side effect, the IO
  # buffer is flushed before determining the size.
  def size
    if @tmpfile
      @tmpfile.fsync
      @tmpfile.flush
      @tmpfile.stat.size
    else
      0
    end
  end
end

require 'technoweenie/attachment_fu/backends/s3_backend'
module Technoweenie
  module AttachmentFu
    module Backends
      module S3Backend
        protected
        def save_to_storage
          if save_attachment?
            S3Object.store(
              full_filename,
              (temp_path ? File.open(temp_path, "rb") : temp_data),
              bucket_name,
              :content_type => content_type,
              :access => attachment_options[:s3_access]
            )
          end

          @old_filename = nil
          true
        end
      end
    end
  end
end

module Technoweenie
  module AttachmentFu
    # Gets the data from the latest temp file.  This will read the file into memory.
    def temp_data
      if save_attachment?
        f = File.new( temp_path )
        f.binmode
        return f.read
      else
        return nil
      end
    end
  end
end
