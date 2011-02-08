class ClippingImage < Asset
  include UrlUpload
  has_attached_file :clipping_image_file, default_s3_options.merge(
    :storage => :s3,
    :styles => { :original => '465>', :thumb => "100x100#", :medium_square => "200x200#", :medium => "200>" },
    :path => "/:attachment/:id/:basename:maybe_style.:extension")
  validates_attachment_presence :clipping_image_file
  validates_attachment_content_type :clipping_image_file, :content_type => ['image/jpg', 'image/jpeg', 'image/pjpeg', 'image/gif', 'image/png', 'image/x-png']
  validates_attachment_size :clipping_image_file, :less_than => 3.megabytes
end
