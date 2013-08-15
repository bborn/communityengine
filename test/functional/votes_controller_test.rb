require 'test_helper'

class VotesControllerTest < ActionController::TestCase
  fixtures :users, :posts, :roles

  def setup
    Vote.destroy_all
    Poll.destroy_all
  end

  def test_should_create_vote    
    assert posts(:funny_post).create_poll({:question => 'Who can have a great time?'}, ['I can', 'You can', 'No one can'])
      
    poll = posts(:funny_post).poll
    
    assert_equal 0, poll.votes_count
    
    login_as :quentin
    assert_difference Vote, :count, 1 do
      post :create, :choice_id => Choice.first.id, :format => 'js'
    end
    assert_response :success
    
    assert_equal 1, poll.reload.votes_count    
  end

end
