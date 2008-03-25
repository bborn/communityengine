require File.dirname(__FILE__) + '/../test_helper'

class CommentTest < Test::Unit::TestCase
  fixtures :comments, :users, :posts

  def test_should_find_comments_by_user
    comments = Comment.find_comments_by_user(users(:quentin))
    assert !comments.empty?
  end

  # def test_should_generate_commetable_url
  #   assert_equal "http://localhost:3000/quentin/posts/1-This-is-really-good-stuff#comment_1", comments(:quentins_comment_on_his_own_post).generate_commentable_url
  # end

end
  