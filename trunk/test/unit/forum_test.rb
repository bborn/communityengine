require File.dirname(__FILE__) + '/../test_helper'

class ForumTest < Test::Unit::TestCase
  all_fixtures

  def test_should_list_only_top_level_topics
    assert_models_equal [topics(:sticky), topics(:il8n), topics(:ponies), topics(:pdi)], forums(:rails).topics
  end

  def test_should_list_recent_posts
    assert_models_equal [sb_posts(:il8n), sb_posts(:ponies), sb_posts(:pdi_rebuttal), sb_posts(:pdi_reply), sb_posts(:pdi),sb_posts(:sticky) ], forums(:rails).sb_posts
  end

  def test_should_find_last_post
    assert_equal sb_posts(:il8n), forums(:rails).sb_posts.last
  end

  def test_should_find_first_topic
    assert_equal topics(:sticky), forums(:rails).topics.first
  end

  def test_should_find_first_recent_post
    assert_equal topics(:il8n), forums(:rails).recent_topics.first
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
