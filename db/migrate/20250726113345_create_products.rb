class CreateProducts < ActiveRecord::Migration[7.2]
  def change
    create_table :products do |t|
      t.references :user, null: false, foreign_key: true
      t.string :name
      t.integer :category
      t.string :store_name
      t.text :description
      t.float :richness
      t.float :bitterness
      t.float :sweetness
      t.float :aftertaste
      t.float :appearance
      t.float :total_rating

      t.timestamps
    end
  end
end
