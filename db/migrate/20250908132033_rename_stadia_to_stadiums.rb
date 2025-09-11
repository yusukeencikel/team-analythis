class RenameStadiaToStadiums < ActiveRecord::Migration[7.0]
  def change
    rename_table :stadia, :stadiums
  end
end