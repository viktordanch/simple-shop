class UserMailer < ApplicationMailer
  def create_order(order_id)
    @order = Order.find_by_id(order_id)
    @user = @order.user
    mail(to: @user.email, subject: I18n.t('Order successfully created'))
  end
  def create_order_admin(order_id)
    @order = Order.find_by_id(order_id)
    @user = @order.user
    mail(to: ENV['EMAIL'], from: @user.email, subject: I18n.t('Order successfully created'))
  end
end
