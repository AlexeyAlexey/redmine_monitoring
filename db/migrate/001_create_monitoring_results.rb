class CreateMonitoringResults < ActiveRecord::Migration
  def change(postfix)
    create_table "monitoring_results" do |t|
      t.datetime :monitoring_day,  null: false
      t.text     :result, default: ""

      t.timestamps null: false
    end
    add_index "monitoring_results", [:project_id]
    add_index "monitoring_results", [:server_id]
  end

  def down(postfix)
    drop_table "monitoring_results"
  end
end