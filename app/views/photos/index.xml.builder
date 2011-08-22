xml.instruct!

xml.gallery do 
  xml.album :title=>:photos.l(:count => @photos.size), :lgPath=>"", :tnPath=>"" do 
    @photos.each do |photo|
      xml.img :src=> photo.photo.url(:large), :tn=> photo.photo.url(:thumb), :link => user_photo_url(@user, photo)
    end
  end
end
