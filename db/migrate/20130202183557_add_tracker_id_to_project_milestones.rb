class AddTrackerIdToProjectMilestones < ActiveRecord::Migration
  def self.up
    add_column :project_milestones, :tracker_id, :integer
  end

  def self.down
    remove_column :project_milestones, :tracker_id
  end
end
