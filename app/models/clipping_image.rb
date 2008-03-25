class ClippingImage < Asset
  has_attachment  :content_type => :image,
    :storage => :s3, 
    :max_size => 3.megabytes,
    :resize_to  => "465>",
    :path_prefix => "assets", 
    :thumbnails => { :thumb => "100x100!", :medium_square => '200x200!', :medium => "200>" }

  validates_as_attachment
end