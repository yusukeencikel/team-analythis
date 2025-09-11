 class RefactorInningsPitchedToOuts < ActiveRecord::Migration[7.0]
      def change
        # 1. 新しい outs_pitched カラムを整数型で追加
        add_column :pitching_stats, :outs_pitched, :integer, default: 0, null: false
        
        # 2. (もし既存データがあれば) innings_pitched の値をアウト数に変換して移し替える
        # この処理は、既存データがない場合は不要ですが、安全のために記述します。
        PitchingStat.find_each do |stat|
          if stat.innings_pitched.present?
            innings = stat.innings_pitched.to_i
            thirds = (stat.innings_pitched.to_f * 10 % 10).round
            outs = (innings * 3) + thirds
            stat.update_column(:outs_pitched, outs)
          end
        end
        
        # 3. 不要になった古い innings_pitched カラムを削除
        remove_column :pitching_stats, :innings_pitched, :float
      end
    end