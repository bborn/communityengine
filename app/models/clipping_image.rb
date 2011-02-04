class ClippingImage < Asset
  include UrlUpload
  has_attachment prepare_options_for_attachment_fu(configatron.clipping.attachment_fu_options.to_hash)
  
  validates_as_attachment
end