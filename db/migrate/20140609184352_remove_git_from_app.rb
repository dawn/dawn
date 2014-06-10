class RemoveGitFromApp < ActiveRecord::Migration
  def change
    remove_column :apps, :git
  end
end
