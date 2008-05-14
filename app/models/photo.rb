class Photo < ActiveRecord::Base
  acts_as_commentable
  
  has_attachment prepare_options_for_attachment_fu(AppConfig.photo['attachment_fu_options'])

  acts_as_taggable

  acts_as_activity :user, :if => Proc.new{|record| record.parent.nil?}

  validates_presence_of :size
  validates_presence_of :content_type
  validates_presence_of :filename
  validates_presence_of :user, :if => Proc.new{|record| record.parent.nil? }
  validates_inclusion_of :content_type, :in => attachment_options[:content_type], :message => "is not allowed", :allow_nil => true
  validates_inclusion_of :size, :in => attachment_options[:size], :message => " is too large", :allow_nil => true
  
  belongs_to :user
  has_one :user_as_avatar, :class_name => "User", :foreign_key => "avatar_id"

  attr_protected :user_id

  def display_name
    self.name ? self.name : self.created_at.strftime("created on: %m/%d/%y")
  end
  
  def link_for_rss
    "#{APP_URL}/#{self.user.login}/photos/#{self.to_param}"
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

  def self.find_recent(options = {:limit => 3})
    find(:all, :conditions => ["created_at > ? AND parent_id IS NULL", 7.days.ago.to_s(:db)], :order => "created_at DESC", :limit => options[:limit])
  end
  
  def self.find_related_to(photo, options = {})
    merged_options = options.merge({:limit => 8, 
        :order => 'created_at DESC', 
        :sql => " AND photos.id != '#{photo.id}' GROUP BY photos.id"})
    photo = find_tagged_with(photo.tags.collect{|t| t.name }, merged_options)
  end
  
  # Used to set cache expiry on S3 photos. Not really needed anymore.
  # def self.set_cache_control
  #   photos = Photo.find(:all)
  #   photos.each do |photo|
  #     begin
  #       s3_object = AWS::S3::S3Object.find(photo.full_filename, "#{AppConfig.community_name.downcase}_uploads_#{RAILS_ENV}")
  #       s3_object.save(:access => :public_read) unless s3_object.cache_control && s3_object.expires
  #     rescue Exception => e
  #       logger.error("Unable to update photo with key " +
  #         "#{photo.full_filename}: #{e}")
  #     end
  #   end
  # end

end