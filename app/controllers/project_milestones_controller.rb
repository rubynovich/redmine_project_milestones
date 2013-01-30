class ProjectMilestonesController < ApplicationController
  unloadable

  before_filter :new_project_milestone, :only => [:new, :index, :create] 
  before_filter :find_project_milestone, :only => [:edit, :update, :destroy]
  before_filter :find_project, :only => [:new, :index, :create]
  before_filter :find_issues, :only => [:new, :edit]
  before_filter :require_project_milestones_manager
  
  def index
    @project_milestones = ProjectMilestone.for_project(@project.id).all(:order => :subject)
  end

  def new
  end
  
  def edit
  end
  
  def update
    if @project_milestone.update_attributes(params[:project_milestone])
      flash[:notice] = l(:notice_successful_update)
      redirect_back_or_default :action => :index
    else
      render :action => :edit
    end
  end
  
  def create
    if @project_milestone.present? && @project_milestone.save
      flash[:notice] = l(:notice_successful_create)
      redirect_back_or_default :action => :index
    else
      render :action => :new
    end
  end
  
  def destroy
    if @project_milestone.present? && @project_milestone.destroy
      flash[:notice] = l(:notice_successful_delete)
    end
    redirect_back_or_default :action => :index
  end

  private
  
    def find_project_milestone
      @project_milestone = ProjectMilestone.find(params[:id])      
    end

    def find_project
      project_id = params[:project_id]
      @project = Project.find(project_id)
    rescue ActiveRecord::RecordNotFound
      render_404
    end

    def new_project_milestone
      @project_milestone = ProjectMilestone.new(params[:project_milestone])
    end

    def require_project_milestones_manager
      (render_403; return false) unless User.current.allowed_to?({:controller => :project_milestones, :action => params[:action]}, nil, {:global => true})
    end
end
