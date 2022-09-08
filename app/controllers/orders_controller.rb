class OrdersController < ApplicationController
  def create
    @order = Order.new(order_params)
    @pharmacy = Pharmacy.find(params[:pharmacy_id])
    @order.pharmacy = @pharmacy
    @order.user = current_user
    @order.delivered = false # Could have done it when generating the model(default value)

    @medicine = Medicine.find(params[:order][:medicine_id])
    @medicine_stock = @pharmacy.stocks.where(medicine_id: @medicine)
    @stocks = @pharmacy.stocks

    # @available_quantities = @pharmacy.stocks.where(medicine_id: @medicine)
    @available_qty = @medicine_stock[0].quantity

    if @available_qty >= @order.quantity
      if @order.save
        @order.total_price = @order.quantity * @order.medicine.price
        @order.save
        # Reduce stock TODO
        # @order.medicine.stock.quantity -= @order.quantity
        redirect_to pharmacy_path(@pharmacy)
      else
        render "pharmacies/show", status: :unprocessable_entity
      end
    else
      @order.errors.add(:quantity, "There's not enough stock")
      render "pharmacies/show", status: :unprocessable_entity
    end
  end

  private

  def order_params
    params.require(:order).permit(:pharmacy_id, :quantity, :delivery, :medicine_id)
  end
end
