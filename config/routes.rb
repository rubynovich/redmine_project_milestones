if Rails::VERSION::MAJOR >= 3
  RedmineApp::Application.routes.draw do
    resources :project_milestones    
  end
else
  ActionController::Routing::Routes.draw do |map|
    map.resources :project_milestones
  end
end
