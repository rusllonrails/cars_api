class CreateCars < ActiveRecord::Migration[8.0]
  def change
    create_table :cars do |t|
      t.string :model
      t.references :brand, null: false, foreign_key: true
      t.integer :price

      t.timestamps
    end
  end
end
