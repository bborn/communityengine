class VotesController < BaseController
  before_filter :find_choice, :only => [:create]
  before_filter :login_required
  
  def new
    @post = Post.find(params[:post_id])
    redirect_to user_post_path(@post.user, @post)
  end
  
  def create
    @vote = @choice.votes.build(:user => current_user, :poll => @choice.poll )
    
    @vote.save
    respond_to do |format|
      format.js
    end
  end
  
  protected
  
  def find_choice
    @choice = Choice.find(params[:choice_id])    
  end
end
