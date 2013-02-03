class ProjectMilestonesController < ApplicationController
  unloadable

  before_filter :new_project_milestone, :only => [:new, :index, :create] 
  before_filter :find_project_milestone, :only => [:edit, :update, :show, :destroy]
  before_filter :find_issues, :only => [:new, :create, :edit, :update]
  before_filter :find_project, :only => [:index, :new, :edit, :show]  
  before_filter :require_project_milestones_manager

  helper :journals
  helper :issues
  include IssuesHelper
    
  def index
    @project_milestones = ProjectMilestone.for_project(@project.id).all(:order => :subject)
  end

  def new
    @project_milestone.project_id = @project.id
  end
  
  def show
    @journals = @project_milestone.issue.journals.find(:all, :include => [:user, :details], :order => "#{Journal.table_name}.created_on ASC")
    @journals.each_with_index {|j,i| j.indice = i+1}
    @journals.reverse! if User.current.wants_comments_in_reverse_order?    
  end
  
  def update
    if @project_milestone.update_attributes(params[:project_milestone])
      flash[:notice] = l(:notice_successful_update)
      update_project_milestone_issues(params[:issues])
      update_project_milestone_due_date
      redirect_back_or_default :action => :index
    else
      render :action => :edit
    end
  end
  
  def create
    if @project_milestone.present? && @project_milestone.save
      flash[:notice] = l(:notice_successful_create)
      save_project_milestone_issues(params[:issues])
      create_project_milestone_issue
      redirect_back_or_default :action => :index
    else
      render :action => :new
    end
  end
  
  def destroy
    find_project unless @project
    issues = @project_milestone.issues
    if @project_milestone.present? && @project_milestone.destroy
      flash[:notice] = l(:notice_successful_delete)
      issues.each do |issue|
        issue.update_attributes(:project_milestone_id => nil)
      end
    end
    redirect_back_or_default :action => :index, :project_id => @project
  end

  private
  
    def find_project_milestone
      @project_milestone = ProjectMilestone.find(params[:id])      
    end

    def find_project
      project_id = params[:project_id] || @project_milestone.project_id
      @project = Project.find(project_id)
    rescue ActiveRecord::RecordNotFound
      render_404
    end

    def find_issues
      find_project unless @project
      @issues = Issue.visible.open.for_project(@project.id).all(:order => "due_date DESC")
      @issues -= [@project_milestone.issue]
    end
    
    def new_project_milestone
      @project_milestone = ProjectMilestone.new(params[:project_milestone])
    end

    def require_project_milestones_manager
      (render_403; return false) unless User.current.allowed_to?({:controller => :project_milestones, :action => params[:action]}, nil, {:global => true})
    end
    
    def save_project_milestone_issues(issues)
      issues.each do |issue|
        Issue.find(issue).update_attributes(:project_milestone_id => @project_milestone.id)
      end
    end

    def create_project_milestone_issue
      max_due_date = @project_milestone.issues.select(&:due_date).map(&:due_date).max
      @project_milestone.update_attributes :issue => Issue.create(
        :project_id => @project.id, 
        :start_date => max_due_date, 
        :due_date => max_due_date,
        :author => User.current,
        :assigned_to => User.current,
        :tracker => @project_milestone.tracker,
        :subject => @project_milestone.subject,
        :description => @project_milestone.description,
        :priority => IssuePriority.default,
        :status => IssueStatus.default,
        :project => @project
        )
    end
    
    def update_project_milestone_issues(issues)
      @project_milestone.issues.each do |issue|
        if issues.include?(issue.id.to_s)
          issue.update_attributes(:project_milestone_id => @project_milestone.id)
        else
          issue.update_attributes(:project_milestone_id => nil)
        end
      end
    end
        
    def update_project_milestone_due_date
      max_due_date = @project_milestone.issues.select(&:due_date).max_by{ |issue| issue.due_date }
      pm_issue = @project_milestone.issue
      if pm_issue.due_date < max_due_date.due_date
        pm_issue.init_journal(User.current, t("message_project_milestone_update_delayed", :start_date => pm_issue.due_date, :due_date => max_due_date.due_date, :issue => "##{max_due_date.id}"))
        pm_issue.due_date = max_due_date.due_date
        pm_issue.save
      end
    end
end
