require File.dirname(__FILE__) + '/../test_helper'

class ForumTest < ActiveSupport::TestCase
  fixtures :all

  def test_should_list_only_top_level_topics
    assert_equal [topics(:sticky), topics(:il8n), topics(:ponies), topics(:pdi)], forums(:rails).topics.order('sticky DESC, created_at DESC').all
  end

  def test_should_find_first_recent_post
    assert_equal topics(:il8n), forums(:rails).topics.recently_replied.first
  end

  def test_should_format_body_html
    forum = Forum.new(:description => 'foo')
    forum.send :format_content
    assert_not_nil forum.description_html
    
    forum.description = ''
    forum.send :format_content
    assert forum.description_html.blank?
  end
end
