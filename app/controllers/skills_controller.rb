class SkillsController < BaseController
  before_filter :login_required, :only => [:new, :create, :edit, :update, :destroy]
  before_filter :admin_required, :only => [:new, :create, :edit, :update, :destroy]

  # GET /skills
  # GET /skills.xml
  def index
    @skills = Skill.find(:all)

    cond = Caboose::EZ::Condition.new
    cond.append ['activated_at is not null ']
    cond.vendor == true
    
    @pages, @users = paginate :users, :order => "created_at DESC", :conditions => cond.to_sql, :include => :tags

    @tags = User.tags_count :limit => 10

    @active_users = User.find(:all,
      :include => [:posts, :offerings],
      :limit => 5,
      :conditions => ["users.updated_at > ? AND vendor = ?", 5.days.ago, true],
      :order => "users.view_count DESC")

    respond_to do |format|
      format.html # index.rhtml
      format.xml  { render :xml => @skills.to_xml }
    end
  end
  
  # GET /skills/1
  # GET /skills/1.xml
  def show
    @skill = Skill.find(params[:id])
    
    @active_users = User.find(:all,
      :include => [:posts, :offerings],
      :limit => 5,
      :conditions => ["offerings.skill_id = ? AND users.updated_at > ? AND vendor = ?", @skill.id, 5.days.ago, true],
      :order => "users.view_count DESC")
    
    respond_to do |format|
      format.html # show.rhtml
      format.xml  { render :xml => @skill.to_xml }
    end
  end
  
  # GET /skills/new
  def new
    @skill = Skill.new
  end
  
  # GET /skills/1;edit
  def edit
    @skill = Skill.find(params[:id])
  end

  # POST /skills
  # POST /skills.xml
  def create
    @skill = Skill.new(params[:skill])
    
    respond_to do |format|
      if @skill.save
        flash[:notice] = 'Skill was successfully created.'
        
        format.html { redirect_to skill_url(@skill) }
        format.xml do
          headers["Location"] = skill_url(@skill)
          render :nothing => true, :status => "201 Created"
        end
      else
        format.html { render :action => "new" }
        format.xml  { render :xml => @skill.errors.to_xml }
      end
    end
  end
  
  # PUT /skills/1
  # PUT /skills/1.xml
  def update
    @skill = Skill.find(params[:id])
    
    respond_to do |format|
      if @skill.update_attributes(params[:skill])
        format.html { redirect_to skill_url(@skill) }
        format.xml  { render :nothing => true }
      else
        format.html { render :action => "edit" }
        format.xml  { render :xml => @skill.errors.to_xml }        
      end
    end
  end
  
  # DELETE /skills/1
  # DELETE /skills/1.xml
  def destroy
    @skill = Skill.find(params[:id])
    @skill.destroy
    
    respond_to do |format|
      format.html { redirect_to skills_url   }
      format.xml  { render :nothing => true }
    end
  end
end