class CreateUsers < ActiveRecord::Migration[6.1]
  def change
    create_table :users do |t|
      t.string :name
      t.string :email, unique: true
      t.string :password_digest
      t.string :role
      t.string :token
      t.boolean :locked, default: false
      t.datetime :locked_at

      t.timestamps
    end

    add_index :users, :email
    add_index :users, :token
  end
end
