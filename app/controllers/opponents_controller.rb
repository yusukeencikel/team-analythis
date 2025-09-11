class OpponentsController < ApplicationController
  before_action :set_opponent, only: [:edit, :update, :destroy] # :show を削除
  before_action :load_stadiums, only: [:new, :edit, :create, :update]

  def index
    @opponents = Opponent.all.order(:id)
  end

  def new
    @opponent = Opponent.new
  end

  def create
    @opponent = Opponent.new(opponent_params)
    if @opponent.save
      redirect_to opponents_path, notice: '対戦相手を登録しました。'
    else
      render :new, status: :unprocessable_entity
    end
  end

  def edit
  end

  def update
    if @opponent.update(opponent_params)
      redirect_to opponents_path, notice: '対戦相手の情報を更新しました。'
    else
      render :edit, status: :unprocessable_entity
    end
  end

  def destroy
    @opponent.destroy
    redirect_to opponents_path, notice: '対戦相手を削除しました。'
  end

  private

  def set_opponent
    @opponent = Opponent.find(params[:id])
  end
  
  def load_stadiums
    @stadiums = Stadium.all.order(:name)
  end

  def opponent_params
    params.require(:opponent).permit(:name, :short_name, :stadium_id)
  end
end
