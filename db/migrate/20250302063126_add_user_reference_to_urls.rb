class AddUserReferenceToUrls < ActiveRecord::Migration[7.1]
  def change
    add_reference :urls, :user, null: true, foreign_key: true
  end
end
