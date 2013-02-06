if Rails::VERSION::MAJOR >= 3
  RedmineApp::Application.routes.draw do
    resources :project_milestones
    resources :milestone_issues
  end
else
  ActionController::Routing::Routes.draw do |map|
    map.resources :project_milestones
    map.resources :milestone_issues
  end
end
