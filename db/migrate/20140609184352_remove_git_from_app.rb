class RemoveGitFromApp < ActiveRecord::Migration
  def change
    rename_column :apps, :git, :deprecated_git_2014_06_10
  end
end
