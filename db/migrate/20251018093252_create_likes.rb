class CreateLikes < ActiveRecord::Migration[7.2]
  def change
    create_table :likes do |t|
      t.references :user, null: false, foreign_key: true
      t.references :review, null: false, foreign_key: true

      t.timestamps
    end
    # ユーザーごとにレビューに対して1回だけいいねできるようにする
    add_index :likes, [ :user_id, :review_id ], unique: true
  end
end
