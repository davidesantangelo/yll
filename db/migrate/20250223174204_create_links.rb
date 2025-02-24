class CreateLinks < ActiveRecord::Migration[8.0]
  def change
    create_table :links do |t|
      t.string :url
      t.string :password_digest
      t.datetime :expires_at
      t.string :code
      t.integer :clicks, default: 0

      t.timestamps
    end

    add_index :links, :url
    add_index :links, :code, unique: true
    add_index :links, :clicks
  end
end
