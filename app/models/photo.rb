class Photo < ActiveRecord::Base
  include UrlUpload

  acts_as_commentable
  belongs_to :album

  has_attached_file :photo, configatron.photo.paperclip_options.to_hash
  validates_attachment_presence :photo, :unless => Proc.new{|record| record.photo_remote_url }
  validates_attachment_content_type :photo, :content_type => configatron.photo.validation_options.content_type
  validates_attachment_size :photo, :less_than => configatron.photo.validation_options.max_size.to_i.megabytes

  attr_accessor :crop_x, :crop_y, :crop_w, :crop_h, :photo_remote_url
  after_update :reprocess_photo, :if => :cropping?

  acts_as_taggable

  acts_as_activity :user, :if => Proc.new{|record| record.album_id.nil?}

  validates_presence_of :user

  belongs_to :user
  has_one :user_as_avatar, :class_name => "User", :foreign_key => "avatar_id", :inverse_of => :avatar

  #Named scopes
  scope :recent, lambda { order("photos.created_at DESC") }
  scope :new_this_week, lambda { order("photos.created_at DESC").where("photos.created_at > ?", 7.days.ago.iso8601) }

  def display_name
    (self.name && self.name.length>0) ? self.name : "#{:created_at.l.downcase}: #{I18n.l(self.created_at, :format => :published_date)}"
  end

  def description_for_rss
    "<a href='#{self.link_for_rss}' title='#{self.name}'><img src='#{self.photo.url(:large)}' alt='#{self.name}' /><br />#{self.description}</a>"
  end

  def owner
    self.user
  end

  def previous_photo
    self.user.photos.where('created_at < ?', created_at).first
  end
  def next_photo
    self.user.photos.where('created_at > ?', created_at).last
  end

  def previous_in_album
    return nil unless self.album
    self.user.photos.where('created_at < ? and album_id = ?', created_at, self.album.id).first
  end
  def next_in_album
    return nil unless self.album
    self.user.photos.where('created_at > ? and album_id = ?', created_at, self.album_id).last
  end


  def self.find_recent(options = {:limit => 3})
    self.new_this_week.limit(options[:limit])
  end

  def self.find_related_to(photo, options = {})
    options.reverse_merge!({:limit => 8,
        :order => 'created_at DESC',
        :conditions => ['photos.id != ?', photo.id]
    })
    limit(options[:limit]).order(options[:order]).where(options[:conditions]).tagged_with(photo.tags.collect{|t| t.name }, :any => true)
  end

  def cropping?
    !crop_x.blank? && !crop_y.blank? && !crop_w.blank? && !crop_h.blank?
  end

  def photo_geometry(style = :original)
    @geometry ||= {}
    @geometry[style] ||= Paperclip::Geometry.from_file(photo.path(style))
  end

  def photo_remote_url=(url_value)
    data = self.data_from_url(url_value)
    self.photo = data
  end

  private

  def reprocess_photo
    photo.reprocess!
  end

end
