class VotesController < BaseController
  before_action :find_choice, :only => [:create]
  before_action :login_required
  
  def new
    @post = Post.find(params[:post_id])
    redirect_to user_post_path(@post.user, @post)
  end
  
  def create
    @vote = @choice.votes.new(:user => current_user, :poll => @choice.poll )
    
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
