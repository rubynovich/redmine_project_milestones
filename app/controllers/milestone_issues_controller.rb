class MilestoneIssuesController < ApplicationController
  unloadable
  before_filter :require_milestone_issues_manager
  before_filter :find_issue, :only => [:new, :edit, :create, :update, :destroy]
  before_filter :all_project_milestones, :only => [:new, :edit, :create, :update]
  before_filter :find_project_milestone, :only => [:create, :update]

  def create
    if @project_milestone && @issue.update_attributes(:project_milestone => @project_milestone)
      flash[:notice] = l(:notice_successful_create)
      reopen_milestone_issue
      redirect_to project_milestone_path(@project_milestone)
    else
      render :action => :new
    end
  end

  def update
    if @project_milestone && @issue.update_attributes(:project_milestone => @project_milestone)
      flash[:notice] = l(:notice_successful_update)
      reopen_milestone_issue
      redirect_to project_milestone_path(@project_milestone)
    else
      render :action => :edit
    end
  end

  def edit
    @project_milestone = @issue.project_milestone
  end

  def destroy
    if @issue.update_attributes(:project_milestone_id => nil)
      flash[:notice] = l(:notice_successful_delete)
    end
    redirect_back_or_default issue_path(@issue)
  end

  private
    def reopen_milestone_issue
      if !@issue.closed? && @project_milestone.issue.closed?
        milestone_issue = @project_milestone.issue
        milestone_issue.init_journal(User.current, t(:message_project_milestone_issue_reopened))
        milestone_issue.status = IssueStatus.default
        milestone_issue.save
      end
    end

    def require_milestone_issues_manager
      (render_403; return false) unless User.current.allowed_to?({:controller => :milestone_issues, :action => params[:action]}, nil, {:global => true})
    end

    def all_project_milestones
      find_issue unless @issue && @project
      @project_milestones = ProjectMilestone.for_project(@project.id).exclude_issue(@issue.id).all(:order => :subject)
    end

    def find_issue
      issue_id = params[:issue_id] || params[:id]
      @issue = Issue.find(issue_id)
      @project = @issue.project
    rescue ActiveRecord::RecordNotFound
      render_404
    end

    def find_project_milestone
      if params[:project_milestone_id].present?
        @project_milestone = ProjectMilestone.find(params[:project_milestone_id])
      else
        flash[:error] = l(:notice_no_project_milestone_selected)
      end
    end
end
