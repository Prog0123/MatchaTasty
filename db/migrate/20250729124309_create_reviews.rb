class CreateReviews < ActiveRecord::Migration[7.2]
  def change
    create_table :reviews do |t|
      t.references :product, null: false, foreign_key: true
      t.references :user, null: false, foreign_key: true
      t.text :comment
      t.integer :rating
      t.float :score, null: false
      t.integer :taste_level, null: false, default: 0 # 味の濃さ

      t.timestamps
    end
  end
end
