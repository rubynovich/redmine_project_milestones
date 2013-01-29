class ProjectMilestone < ActiveRecord::Base
  unloadable
  
  belongs_to :issue
  belongs_to :project
  has_many :issues
  
  validates_presence_of :subject
  validates_uniqueness_of :issue_id
end
