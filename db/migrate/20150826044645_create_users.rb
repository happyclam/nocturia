class CreateUsers < ActiveRecord::Migration
  def change
    create_table :users do |t|
      t.string :name
      t.string :provider
      t.string :screen_name
      t.string :uid
      t.string :deviceid

      t.timestamps null: false
    end
  end
end
