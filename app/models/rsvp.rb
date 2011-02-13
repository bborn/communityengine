class Rsvp < ActiveRecord::Base
  acts_as_activity :user
  validates_numericality_of :attendees_count, :only_integer=>true, :greater_than=>0
  validates_presence_of :event, :user
  validates_uniqueness_of :user_id, :scope => :event_id, :message => I18n.t(:you_have_already_rsvped_for_this_event)
  validate :event_in_future
  validate :event_allows_rsvp

  belongs_to :user
  belongs_to :event

  attr_protected :user_id
  attr_protected :event_id

private

  def event_allows_rsvp
    errors.add(:base, :event_does_not_allow_rsvp.l) unless self.event.allow_rsvp?
  end

  def event_in_future
    errors.add(:base, :cannot_rsvp_for_an_event_that_has_already_happened.l) if self.event.end_time < Time.now
  end
end
