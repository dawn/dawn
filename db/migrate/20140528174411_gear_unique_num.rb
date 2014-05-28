class GearUniqueNum < ActiveRecord::Migration
  def change
    add_index :gears, [:number, :proctype], unique: true
  end
end
