class AddOurTeamToPlayers < ActiveRecord::Migration[6.1]
  def change
    add_reference :players, :our_team, foreign_key: true
  end
end