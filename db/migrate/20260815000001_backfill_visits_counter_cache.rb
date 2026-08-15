class BackfillVisitsCounterCache < ActiveRecord::Migration[7.2]
  # visits_count was maintained by hand and could drift from the visits table.
  # It is now a real counter cache, so resynchronise it and forbid NULLs.
  def up
    change_column_default :urls, :visits_count, from: 0, to: 0
    change_column_null :urls, :visits_count, false, 0

    Url.reset_column_information
    Url.find_each { |url| Url.reset_counters(url.id, :visits) }
  end

  def down
    change_column_null :urls, :visits_count, true
  end
end
