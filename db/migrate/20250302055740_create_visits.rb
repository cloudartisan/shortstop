class CreateVisits < ActiveRecord::Migration[7.1]
  def change
    create_table :visits do |t|
      t.references :url, null: false, foreign_key: true
      t.string :ip_address
      t.string :user_agent
      t.string :referer

      t.timestamps
    end
    
    add_index :visits, :created_at
  end
end
