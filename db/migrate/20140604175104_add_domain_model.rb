class AddDomainModel < ActiveRecord::Migration

  def change
    remove_column :apps, :domains

    create_table :domains do |t|
      t.timestamps

      t.string :url

      t.belongs_to :app
    end

    add_index :domains, :url, unique: true
  end

end
