class AddLocationToProducts < ActiveRecord::Migration[7.2]
  def change
    add_column :products, :address, :text
    add_column :products, :latitude, :decimal, precision: 10, scale: 6
    add_column :products, :longitude, :decimal, precision: 10, scale: 6
  end
end
