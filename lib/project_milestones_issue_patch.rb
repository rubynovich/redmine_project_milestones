require_dependency 'principal'
require_dependency 'user'
require_dependency 'issue'
require_dependency 'issue_status'

module ProjectMilestonesPlugin
  module IssuePatch
    def self.included(base)
      base.extend(ClassMethods)

      base.send(:include, InstanceMethods)

      base.class_eval do
        belongs_to :project_milestone

        after_save :recalculate_due_date, :if => "self.project_milestone && self.project_milestone.issue && (self.project_milestone.issue.due_date < self.due_date)"
        after_save :close_milestone_issue, :if => "self.project_milestone && self.project_milestone.issue && self.closed? && !self.project_milestone.issue.closed?"

        if Rails::VERSION::MAJOR < 3
          named_scope :for_project, lambda{ |project_id|
            if project_id.present?
              { :conditions =>
                {:project_id => project_id}
              }
            end
          }
        else
          scope :for_project, lambda{ |project_id|
            if project_id.present?
              { :conditions =>
                {:project_id => project_id}
              }
            end
          }
        end
      end
    end

    module ClassMethods

    end

    module InstanceMethods
      def recalculate_due_date
        milestone_issue = self.project_milestone.issue
        milestone_issue.init_journal(User.current, ::I18n.t('message_project_milestone_issue_delayed',
          :issue => "##{self.id}",
          :start_date => format_date(milestone_issue.due_date),
          :due_date => format_date(self.due_date)))
        milestone_issue.due_date = self.due_date
        milestone_issue.save
      end

      def close_milestone_issue
        if self.project_milestone.issues.all?{ |issue| issue.closed? }
          milestone_issue = self.project_milestone.issue
          milestone_issue.init_journal(User.current, ::I18n.t('message_project_milestone_issue_is_closed'))
          milestone_issue.status = IssueStatus.all(:conditions => {:is_closed => true}).last #FIXME from Setting
          milestone_issue.save
        end
      end
    end
  end
end
