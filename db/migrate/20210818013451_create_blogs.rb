class CreateBlogs < ActiveRecord::Migration[6.1]
  def change
    create_table :blogs do |t|
      t.string :title, unique: true
      t.string :slug, unique: true
      t.text :content
      t.integer :creator_id
      t.datetime :published_at

      t.timestamps
    end

    add_index :blogs, :creator_id
  end
end
