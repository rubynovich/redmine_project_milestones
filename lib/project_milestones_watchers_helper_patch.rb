require_dependency 'watchers_helper'

module ProjectMilestonesPlugin
  module WatchersHelperPatch
    def self.included(base)
      base.send(:include, InstanceMethods)

      base.class_eval do
        alias_method_chain :watcher_tag, :milestone_issues
      end
    end

    module InstanceMethods
      def watcher_tag_with_milestone_issues(object, user, options={})
        if (object.class == Issue)&&!object.closed?&&(user.allowed_to?({:controller => :milestone_issues, :action => :new}, nil, {:global => true}))
          [watcher_tag_without_milestone_issues(object, user, options),
          content_tag("span", :class => :milestone_issues) do
            if object.project_milestone.present?
              link_to(t(:button_milestone_issue_edit),
                {:action => :edit, :controller => :milestone_issues, :issue_id => object.id, :project_id => object.project_id},
                {:class => "icon icon-edit"})
            else
              link_to(t(:button_milestone_issue_new),
                {:action => :new, :controller => :milestone_issues, :issue_id => object.id, :project_id => object.project_id},
                {:class => "icon icon-add"})
            end
          end].html_safe
        else
          watcher_tag_without_milestone_issues(object, user, options)
        end
      end
    end
  end
end
