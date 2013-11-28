class ClippingImage < Asset
  include UrlUpload

  has_attached_file :asset, configatron.clipping.paperclip_options.to_hash
  validates_attachment_presence :asset
  validates_attachment_content_type :asset, :content_type => configatron.clipping.validation_options.content_type
  validates_attachment_size :asset, :less_than => configatron.clipping.validation_options.max_size.to_i.megabytes

end
