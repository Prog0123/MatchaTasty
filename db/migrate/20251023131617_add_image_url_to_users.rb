class AddImageUrlToUsers < ActiveRecord::Migration[7.2]
  def change
    add_column :users, :image_url, :string
  end
end
