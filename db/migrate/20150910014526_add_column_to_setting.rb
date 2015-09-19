class AddColumnToSetting < ActiveRecord::Migration
  def change
    add_column :settings, :startdateymd, :string
    add_column :settings, :enddateymd, :string
  end
end
