class PoolsController < ApplicationController
before_action :set_pool, only: [:show]
helper_method :sort_column, :sort_direction

  def index
    @pools = Pool.order(sort_column + " " + sort_direction)
  end

  def show
  end

  private
  def set_pool
    @pool = Pool.find(params[:id])
  end
  def sort_column
    Pool.column_names.include?(params[:sort]) ? params[:sort] : "name"
  end

  def sort_direction
    %w[asc desc].include?(params[:direction]) ? params[:direction] : "asc"
  end
end
