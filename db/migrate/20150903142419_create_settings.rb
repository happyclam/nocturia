class CreateSettings < ActiveRecord::Migration
  def change
    create_table :settings do |t|
      t.integer :duration
      t.references :user, index: true, foreign_key: true

      t.timestamps null: false
    end
  end
end
