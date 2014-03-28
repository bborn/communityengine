class ClippingImage < Asset
  include UrlUpload
  
  has_attached_file :asset, configatron.clipping.paperclip_options
  validates_attachment_presence :asset, :message => :photo_presence_error.l
  validates_attachment_content_type :asset, :content_type => configatron.clipping.validation_options.content_type, :message => :photo_content_type_error.l
  validates_attachment_size :asset, :less_than => configatron.clipping.validation_options.max_size.to_i.megabytes, :message => :photo_size_limit_error.l(:count => configatron.clipping.validation_options.max_size)

end
