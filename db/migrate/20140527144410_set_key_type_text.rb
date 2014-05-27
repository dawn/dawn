class SetKeyTypeText < ActiveRecord::Migration

  def change
    change_column :keys, :key, :text
  end

end