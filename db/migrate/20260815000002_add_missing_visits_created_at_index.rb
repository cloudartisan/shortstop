class AddMissingVisitsCreatedAtIndex < ActiveRecord::Migration[7.2]
  # The original CreateVisits migration added this index but it never made it
  # into db/schema.rb, so schema:load and migrate produced different databases.
  def change
    add_index :visits, :created_at, if_not_exists: true
  end
end
