require 'test_helper'

class ModeratorsControllerTest < ActionController::TestCase
  all_fixtures


  def test_should_delete_moderatorship
    assert users(:sam).moderator_of?(forums(:rails))
    login_as :admin
    assert_difference Moderatorship, :count, -1 do
      delete :destroy, :user_id => users(:sam).id, :id => moderatorships(:sam_rails).id
    end
    assert !users(:sam).moderator_of?(forums(:rails))
  end

  def test_should_only_allow_admins_to_delete_moderatorships
    login_as :sam
    assert_difference Moderatorship, :count, 0 do
      delete :destroy, :user_id => users(:sam).id, :id => moderatorships(:sam_rails).id
    end
  end
end
