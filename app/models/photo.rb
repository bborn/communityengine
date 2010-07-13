class Photo < ActiveRecord::Base
  acts_as_commentable
  belongs_to :album
  
  has_attachment prepare_options_for_attachment_fu(AppConfig.photo['attachment_fu_options'])

  acts_as_taggable

  acts_as_activity :user, :if => Proc.new{|record| record.parent.nil? && record.album_id.nil?}
  
  validates_presence_of :size
  validates_presence_of :content_type
  validates_presence_of :filename
  validates_presence_of :user, :if => Proc.new{|record| record.parent.nil? }
  validates_inclusion_of :content_type, :in => attachment_options[:content_type], :message => "is not allowed", :allow_nil => true
  validates_inclusion_of :size, :in => attachment_options[:size], :message => " is too large", :allow_nil => true
  
  belongs_to :user
  has_one :user_as_avatar, :class_name => "User", :foreign_key => "avatar_id"
  
  #Named scopes
  named_scope :recent, :order => "photos.created_at DESC", :conditions => ["photos.parent_id IS NULL"]
  named_scope :new_this_week, :order => "photos.created_at DESC", :conditions => ["photos.created_at > ? AND photos.parent_id IS NULL", 7.days.ago.to_s(:db)]
  named_scope :tagged_with, lambda {|tag_name|
    {:conditions => ["tags.name = ?", tag_name], :include => :tags}
  }
  attr_accessible :name, :description

  def display_name
    (self.name && self.name.length>0) ? self.name : "#{:created_at.l.downcase}: #{I18n.l(self.created_at, :format => :published_date)}"
  end

  def description_for_rss
    "<a href='#{self.link_for_rss}' title='#{self.name}'><img src='#{self.public_filename(:large)}' alt='#{self.name}' /><br />#{self.description}</a>"
  end

  def owner
    self.user
  end

  def previous_photo
    self.user.photos.find(:first, :conditions => ['created_at < ?', created_at], :order => 'created_at DESC')
  end
  def next_photo
    self.user.photos.find(:first, :conditions => ['created_at > ?', created_at], :order => 'created_at ASC')
  end

  def previous_in_album
    return nil unless self.album
    self.user.photos.find(:first, :conditions => ['created_at < ? and album_id = ?', created_at, self.album.id], :order => 'created_at DESC')
  end
  def next_in_album
    return nil unless self.album    
    self.user.photos.find(:first, :conditions => ['created_at > ? and album_id = ?', created_at, self.album_id], :order => 'created_at ASC')
  end


  def self.find_recent(options = {:limit => 3})
    self.new_this_week.find(:all, :limit => options[:limit])
  end
  
  def self.find_related_to(photo, options = {})
    merged_options = options.merge({:limit => 8, 
        :order => 'created_at DESC', 
        :conditions => ['photos.id != ?', photo.id]
    })
    photo = find_tagged_with(photo.tags.collect{|t| t.name }, merged_options).uniq
  end

end
