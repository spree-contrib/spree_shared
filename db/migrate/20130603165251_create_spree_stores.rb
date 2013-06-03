class CreateSpreeStores < ActiveRecord::Migration
  def change
    create_table :spree_stores do |t|
      t.string :name
      t.string :subdomain

      t.timestamps
    end
  end
end
