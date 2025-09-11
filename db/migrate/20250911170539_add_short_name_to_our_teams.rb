class AddShortNameToOurTeams < ActiveRecord::Migration[7.2]
  def change
    add_column :our_teams, :short_name, :string
  end
end
