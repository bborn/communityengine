require File.dirname(__FILE__) + '/test_helper'
class RssFeedTest < Test::Unit::TestCase
  def setup
    @records = Array.new(5).fill(Post.new)
    @records.each &:save
  end

  def test_default_rss_feed
    rss_feed_for @records

    assert_select 'rss[version="2.0"]' do
      assert_select 'channel' do
        assert_select '>title', 'Posts'
        assert_select '>link',  'http://example.com/posts'
        assert_select 'language', 'en-us'
        assert_select 'ttl', '40'
      end
      assert_select 'item', 5 do
        assert_select 'title', :text => 'feed title (title)'
        assert_select 'description', '&lt;p&gt;feed description (description)&lt;/p&gt;'
        %w(guid link).each do |node|
          assert_select node, 'http://example.com/posts/1'
        end
        assert_select 'pubDate', @records.first.created_at.to_s(:rfc822)
      end
    end
  end
  
  def test_should_allow_custom_feed_options
    rss_feed_for @records, :feed => { :title => 'Custom Posts', :link => '/posts', :description => 'stuff', :language => 'en-gb', :ttl => '80' }
    
    assert_select 'channel>title', 'Custom Posts'
    assert_select 'channel>link',  '/posts'
    assert_select 'channel>description', 'stuff'
    assert_select 'channel>language', 'en-gb'
    assert_select 'channel>ttl', '80'
  end
  
  def test_should_allow_custom_item_attributes
    rss_feed_for @records, :item => { :title => :name, :description => :body, :pub_date => :create_date, :link => :id }

    assert_select 'item', 5 do
      assert_select 'title', :text => 'feed title (name)'
      assert_select 'description', '&lt;p&gt;feed description (body)&lt;/p&gt;'
      assert_select 'pubDate', (@records.first.created_at - 5.minutes).to_s(:rfc822)
      assert_select 'link', '1'
      assert_select 'guid', '1'
    end
  end

  def test_should_allow_custom_item_attribute_blocks
    rss_feed_for @records, :item => { :title => lambda { |r| r.name }, :description => lambda { |r| r.body }, :pub_date => lambda { |r| r.create_date },
      :link => lambda { |r| "/#{r.created_at.to_i}" }, :guid => lambda { |r| r.created_at.to_i } }
    
    assert_select 'item', 5 do
      assert_select 'title', :text => 'feed title (name)'
      assert_select 'description', '&lt;p&gt;feed description (body)&lt;/p&gt;'
      assert_select 'pubDate', (@records.first.created_at - 5.minutes).to_s(:rfc822)
    end
  end
end
