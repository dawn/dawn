class GearStartedAtDatetime < ActiveRecord::Migration

  def change
    change_column :gears, :started_at, "timestamp USING CAST(now() AS TIMESTAMP)"
  end

end
