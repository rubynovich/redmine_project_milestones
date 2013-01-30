class ProjectMilestone < ActiveRecord::Base
  unloadable
  
  belongs_to :issue, :dependent => :destroy
  belongs_to :project
  has_many :issues
  
  validates_presence_of :subject
  validates_uniqueness_of :issue_id

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
