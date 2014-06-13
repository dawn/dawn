class RemoveAppEnvAddReleaseEnv < ActiveRecord::Migration
  def change
    rename_column :apps, :env, :deprecated_env_2014_06_12
    add_column :releases, :env, :hstore, default: {}
  end
end
