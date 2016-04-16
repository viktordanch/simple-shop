# IndexController
class IndexController < ApplicationController
  layout :check_api_params

  def landing
    respond_to do |format|
      format.js { render layout: false }
      format.html
    end
  end

  def about_us
    respond_to do |format|
      format.js { render layout: false }
      format.html
    end
  end

  def contact
    @contact_us_record = ContactUs.new(contact_params)
    if verify_recaptcha
      @contact_us_record.save
      UserMailer.notify_about_contact_us(@contact_us_record.id).deliver_now

      flash[:notice] = I18n.t('Thanks, your request will be reviewed by administration')
      redirect_to :contact_us
    else
      flash.now[:alert] = "#{I18n.t('There was an error with the recaptcha code below')}. #{I18n.t('Please re-enter the code')}"
      render :contact_us
    end
  end

  def contact_us
    respond_to do |format|
      format.js { render layout: false }
      format.html
    end
  end

  def term_of_use
    respond_to do |format|
      format.js { render layout: false }
      format.html
    end
  end

  protected

  def contact_params
    permitted = params.require(:contact_us).permit(:email, :topic, :comment)
  end
end
