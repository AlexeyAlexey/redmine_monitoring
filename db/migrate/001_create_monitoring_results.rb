class CreateMonitoringResults < ActiveRecord::Migration
  def change
    create_table "monitoring_results" do |t|
      t.integer  :project_id
      t.datetime :monitoring_day,  null: false
      t.text     :result

      t.timestamps null: false
    end
    add_index "monitoring_results", ["project_id"], name: "monitoring_results_project_id"
  end

  def down
    drop_table "monitoring_results"
  end
end