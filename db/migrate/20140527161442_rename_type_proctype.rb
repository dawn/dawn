class RenameTypeProctype < ActiveRecord::Migration

  def change
    rename_column :gears, :type, :proctype
  end

end