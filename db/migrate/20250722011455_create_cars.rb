class CreateCars < ActiveRecord::Migration[8.0]
  def change
    create_table :cars do |t|
      t.string :model
      t.integer :year
      t.integer :transmission, default: 0
      t.integer :condition, default: 0
      t.integer :mileage
      t.string :color
      t.decimal :price
      t.references :brand, null: false, foreign_key: true

      t.timestamps
    end
  end
end
