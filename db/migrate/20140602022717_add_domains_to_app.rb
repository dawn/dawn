class AddDomainsToApp < ActiveRecord::Migration

  def change
    change_table :apps do |t|
      t.string :domains, array: true, default: []
    end
  end

end
