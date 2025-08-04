class AddDetailRatingsToReviews < ActiveRecord::Migration[7.2]
  def change
    add_column :reviews, :richness, :float
    add_column :reviews, :bitterness, :float
    add_column :reviews, :sweetness, :float
    add_column :reviews, :aftertaste, :float
    add_column :reviews, :appearance, :float
  end
end
