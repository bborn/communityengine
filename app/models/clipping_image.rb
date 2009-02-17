class ClippingImage < Asset
  include UrlUpload
  has_attachment prepare_options_for_attachment_fu(AppConfig.clipping['attachment_fu_options'])
  
  validates_as_attachment
end