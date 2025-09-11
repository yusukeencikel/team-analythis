class BestOrdersController < ApplicationController
  before_action :set_best_order, only: [:edit, :update, :destroy, :fetch]
  before_action :load_players, only: [:new, :edit, :create, :update]

  def index
    @best_orders = BestOrder.all.order(:name)
  end

  def new
    @best_order = BestOrder.new
    # フォームの初期状態として、1番から9番までの打順を設定した入力欄を用意する
    9.times do |i|
      @best_order.best_order_players.build(batting_order: i + 1)
    end
  end

  def create
    @best_order = BestOrder.new(best_order_params)
    if @best_order.save
      redirect_to best_orders_path, notice: 'ベストオーダーを登録しました。'
    else
      render :new, status: :unprocessable_entity
    end
  end

  def edit
    # @best_order は before_action で設定済み
  end

  def update
    if @best_order.update(best_order_params)
      redirect_to best_orders_path, notice: 'ベストオーダーを更新しました。'
    else
      render :edit, status: :unprocessable_entity
    end
  end

  def destroy
    @best_order.destroy
    redirect_to best_orders_path, notice: 'ベストオーダーを削除しました。'
  end

  # ▼▼▼【ここから追記】▼▼▼
  # GET /best_orders/:id/fetch
  # JavaScriptからの呼び出しに応じて、オーダーのデータをJSON形式で返す
  def fetch
    order_data = @best_order.best_order_players.includes(:player).order(:batting_order).map do |op|
      {
        player_id: op.player_id,
        batting_order: op.batting_order,
        fielding_position: op.fielding_position,
        participation_type: "先発" # 呼び出し時は「先発」をデフォルトで設定
      }
    end
    render json: order_data
  end
  # ▲▲▲【ここまで追記】▲▲▲

  private

  def set_best_order
    @best_order = BestOrder.find(params[:id])
  end

  def load_players
    @players = Player.where(status: 'active').order(:jersey_number)
  end

  def best_order_params
    params.require(:best_order).permit(
      :name,
      best_order_players_attributes: [:id, :player_id, :batting_order, :fielding_position, :_destroy]
    )
  end
end

