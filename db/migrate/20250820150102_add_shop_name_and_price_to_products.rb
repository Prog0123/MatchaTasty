class AddShopNameAndPriceToProducts < ActiveRecord::Migration[7.2]
  def change
    add_column :products, :shop_name, :string
    add_column :products, :price, :integer
  end
end
