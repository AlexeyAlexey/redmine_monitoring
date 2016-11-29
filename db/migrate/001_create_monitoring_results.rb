class CreateMonitoringResults < ActiveRecord::Migration
  def change
    create_table "monitoring_results" do |t|
      t.datetime :monitoring_day,  null: false
      t.text     :result

      t.timestamps null: false
    end
  end

  def down
    drop_table "monitoring_results"
  end
end