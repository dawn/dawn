class RemoveVersionFromAppAndRelease < ActiveRecord::Migration
  def change
    rename_column :apps, :version, :deprecated_version_2014_06_11
    rename_column :releases, :version, :deprecated_version_2014_06_11
  end
end
