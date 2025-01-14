class CreateUsers < ActiveRecord::Migration[8.0]
  def change
    create_table :users do |t|
      t.string :email
      t.int8range :preferred_price_range

      t.timestamps
    end
  end
end
