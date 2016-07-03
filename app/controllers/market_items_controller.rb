class MarketItemsController < ApplicationController
  def index
    @market_items = MarketItem.all
  end

  def new
    @market_item = MarketItem.new
  end

  def create
    MarketItem.transaction do
      @market_item = MarketItem.new(item_params)
      @market_item.save
    end

    redirect_to root_path

  rescue ActiveRecord::ActiveRecordError
    respond_to do |format|
      format.html do
        render 'new'
      end
    end
  end

  def edit
    @market_item = MarketItem.find(params[:id])
  end

  def update
    MarketItem.transaction do
      @market_item = MarketItem.find(params[:id])
      @market_item = MarketItem.update_attributes(item_params)
    end

    redirect_to root_path

  rescue ActiveRecord::ActiveRecordError
    respond_to do |format|
      format.html do
        render 'new'
      end
    end
  end

  def destroy
    @market_item = MarketItem.find(params[:id])
  end

  private

  def item_params
    params.require(:market_item).permit(:name, :description, :picture, :price, :current_quantity)
  end
end