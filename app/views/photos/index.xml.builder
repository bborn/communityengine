xml.instruct!

xml.gallery do 
  xml.album :title=>:photos.l(:count => @photos.size), :lgPath=>"", :tnPath=>"" do 
    @photos.each do |photo|
      xml.img :src=> photo.public_filename(:large), :tn=> photo.public_filename(:thumb), :link => user_photo_url(@user, photo)
    end
  end
end
