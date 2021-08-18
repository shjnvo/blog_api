class CreateUserLikeBlogs < ActiveRecord::Migration[6.1]
  def change
    create_table :user_like_blogs do |t|
      t.references :user, null: false
      t.references :blog, null: false
      t.integer :like_count, default: 0

      t.timestamps
    end
  end
end
