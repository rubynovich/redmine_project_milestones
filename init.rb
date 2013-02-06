require 'redmine'

Redmine::Plugin.register :redmine_project_milestones do
  name 'Вехи'
  author 'Roman Shipiev'
  description 'Плагин позволяет создавать вехи проекта (по сути, специальные задачи). Вехи-задачи автоматически закрываются, если все задачи, от которых зависит веха -- закрыты.'
  version '0.0.1'
  url 'https://github.com/rubynovich/redmine_project_milestones'
  author_url 'http://roman.shipiev.me'

  project_module :project_milestones do
    permission :manage_milestones, {:project_milestones => [:index], :milestone_issues => [:index, :new]}, :public => true
  end

  menu :project_menu, :project_milestones, {:controller => :project_milestones, :action => :index}, :caption => :label_project_milestone_plural, :param => :project_id, :if => Proc.new{ User.current.allowed_to?({:controller => :project_milestones, :action => :index}, nil, {:global => true}) }, :require => :member

  settings :default => {
                         :issue_status => IssueStatus.first(:conditions => {:is_closed => true}).id
                       },
           :partial => 'project_milestones/settings'
end

if Rails::VERSION::MAJOR < 3
  require 'dispatcher'
  object_to_prepare = Dispatcher
else
  object_to_prepare = Rails.configuration
end

object_to_prepare.to_prepare do
  [:issue, :watchers_helper].each do |cl|
    require "project_milestones_#{cl}_patch"
  end

  [
    [Issue, ProjectMilestonesPlugin::IssuePatch],
    [WatchersHelper, ProjectMilestonesPlugin::WatchersHelperPatch]
  ].each do |cl, patch|
    cl.send(:include, patch) unless cl.included_modules.include? patch
  end
end
