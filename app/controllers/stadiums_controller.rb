class StadiumsController < ApplicationController
  before_action :set_stadium, only: [:show, :edit, :update, :destroy]

  def index
    @stadiums = Stadium.all.order(:id)
  end

  def show
  end

  def new
    @stadium = Stadium.new
  end

  def create
    @stadium = Stadium.new(stadium_params)
    if @stadium.save
      redirect_to stadiums_path, notice: '球場を登録しました。'
    else
      render :new, status: :unprocessable_entity
    end
  end

  def edit
  end

  def update
    if @stadium.update(stadium_params)
      redirect_to stadiums_path, notice: '球場の情報を更新しました。'
    else
      render :edit, status: :unprocessable_entity
    end
  end

  def destroy
    @stadium.destroy
    redirect_to stadiums_path, notice: '球場を削除しました。'
  end

  private

  def set_stadium
    @stadium = Stadium.find(params[:id])
  end

  def stadium_params
    params.require(:stadium).permit(:name)
  end
end