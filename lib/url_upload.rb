# Make it always write to tempfiles, never StringIO
OpenURI::Buffer.module_eval {
  remove_const :StringMax
  const_set :StringMax, 0
}
class UrlUpload
  EXTENSIONS = {
    "image/jpeg" => ["jpg", "jpeg", "jpe"],
    "image/gif" => ["gif"],
    "image/png" => ["png"]
  }
  attr_reader :original_filename, :attachment_data, :size

  # Make it always write to tempfiles, never StringIO
  OpenURI::Buffer.module_eval {
    remove_const :StringMax
    const_set :StringMax, 0
  }
  def initialize(url)
    @attachment_data = open(url)
    @original_filename = determine_filename
  end

  # Pass things like size, content_type, path on to the downloaded file
  def method_missing(symbol, *args)
    if self.attachment_data.respond_to? symbol
      self.attachment_data.send symbol, *args
    else
      super
    end
  end
  
  private
    def determine_filename
      # Grab the path - even though it could be a script and not an actual file
      path = self.attachment_data.base_uri.path
      # Get the filename from the path, make it lowercase to handle those
      # crazy Win32 servers with all-caps extensions
      filename = File.basename(path).downcase
      # If the file extension doesn't match the content type, add it to the end, changing any existing .'s to _
      filename = [filename.gsub(/\./, "_"), EXTENSIONS[self.content_type].first].join(".") unless EXTENSIONS[self.content_type].any? {|ext| filename.ends_with?("." + ext) }
      # Return the result
      filename
    end
end

