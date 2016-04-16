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

  def notify_about_contact_us(contact_us_id)
    @contact_us_record = ContactUs.find_by_id(contact_us_id)
    mail(to: ENV['EMAIL'], from: @contact_us_record.email, subject: I18n.t('Contact us record created'))
  end
end
