class CreateUrls < ActiveRecord::Migration[7.1]
  def change
    create_table :urls do |t|
      t.string :original_url, null: false
      t.string :shortened_path
      t.integer :visits_count, default: 0

      t.timestamps
    end
    
    add_index :urls, :shortened_path, unique: true
    add_index :urls, :original_url
  end
end
