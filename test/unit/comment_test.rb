require File.dirname(__FILE__) + '/../test_helper'

class CommentTest < Test::Unit::TestCase
  fixtures :comments, :users, :posts, :roles

  def test_should_find_comments_by_user
    comments = Comment.find_comments_by_user(users(:quentin))
    assert !comments.empty?
  end
  
  def test_comment_can_be_deleted_by
    comment = comments(:aarons_comment_on_quentins_post)
    assert comment.can_be_deleted_by(users(:aaron))
    assert comment.can_be_deleted_by(users(:quentin))    
    assert !comment.can_be_deleted_by(users(:florian))
  end

  def test_should_generate_commetable_url
    assert_equal "#{APP_URL}/quentin/posts/1-Building-communities-is-all-about-love-#comment_1", comments(:quentins_comment_on_his_own_post).generate_commentable_url
  end
  
  def test_should_be_created_anonymously
    AppConfig.allow_anonymous_commenting = true
    assert_difference Comment, :count, 1 do
      comment = Comment.create!(:comment => 'foo', :author_email => 'bar@foo.com', :author_ip => '123.123.123', :recipient => users(:quentin))
    end
    AppConfig.allow_anonymous_commenting = false
  end

  def test_should_not_be_created_anonymously
    assert_no_difference Comment, :count do
      comment = Comment.create(:comment => 'foo', :author_email => 'bar@foo.com', :author_ip => '123.123.123', :recipient => users(:quentin))
    end
  end


end
  