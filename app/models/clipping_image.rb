class ClippingImage < Asset
  include UrlUpload
  has_attached_file :asset, configatron.clipping.paperclip_options
  validates_attachment_presence :asset
  validates_attachment_content_type :photo, :content_type => configatron.clipping.validation_options.content_type
  validates_attachment_size :photo, :less_than => configatron.clipping.validation_options.max_size.to_i.megabytes
end
