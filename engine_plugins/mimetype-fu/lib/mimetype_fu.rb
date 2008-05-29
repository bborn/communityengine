class File

  def self.mime_type?(file)
    if file.class == File
      unless RUBY_PLATFORM.include? 'mswin32'
        mime = `file -ir #{file.path}`.scan(/.*: (.*);(.*)/)[0][0]
      else
        mime = ::EXTENSIONS[File.extname(file.path).gsub('.','').downcase.to_sym]
      end
    elsif file.class == String
      mime = EXTENSIONS[(file[file.rindex('.')+1, file.size]).downcase.to_sym]
    end

    if mime
      return mime
    else 
      'unknown/unknown' 
    end
  end
  
  def self.extensions
    EXTENSIONS
  end
  
end