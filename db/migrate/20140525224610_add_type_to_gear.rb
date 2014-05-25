class AddTypeToGear < ActiveRecord::Migration

  def change
    change_table :gears do |t|
      t.string :type
    end
  end

end