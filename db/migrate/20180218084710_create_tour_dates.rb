class CreateTourDates < ActiveRecord::Migration[5.2]

  # https://robots.thoughtbot.com/how-to-create-postgres-indexes-concurrently-in
  disable_ddl_transaction!
  
  def change
    create_table :tour_dates do |t|
      t.date :day
      t.references :tour, foreign_key: true
      t.references :company, foreign_key: true

      t.timestamps
    end
    add_index :tour_dates, [:day, :tour_id], unique: true, algorithm: :concurrently
  end
end
