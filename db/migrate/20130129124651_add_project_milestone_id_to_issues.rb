class AddProjectMilestoneIdToIssues < ActiveRecord::Migration
  def self.up
    add_column :issues, :project_milestone_id, :integer
  end

  def self.down
    remove_column :issues, :project_milestone_id
  end
end
