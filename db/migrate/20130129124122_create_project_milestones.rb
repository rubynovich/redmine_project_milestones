class CreateProjectMilestones < ActiveRecord::Migration
  def self.up
    create_table :project_milestones do |t|
      t.column :issue_id, :integer
      t.column :project_id, :integer
      t.column :subject, :string
      t.column :description, :text
    end
  end

  def self.down
    drop_table :project_milestones
  end
end
