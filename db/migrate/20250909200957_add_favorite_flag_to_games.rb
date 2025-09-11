class AddFavoriteFlagToGames < ActiveRecord::Migration[7.0]
      def change
        # gamesテーブルに、is_favoriteという名前のboolean型の列を追加します。
        # default: false は、データがなければ自動的にfalse(お気に入りでない)状態にします。
        # null: false は、この項目が空であることを禁止します。
        add_column :games, :is_favorite, :boolean, default: false, null: false
      end
    end