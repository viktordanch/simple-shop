# Order model
class Order < ActiveRecord::Base
  belongs_to :user
  has_many :orders_products, dependent: :destroy
  has_many :products, through: :orders_products
  has_and_belongs_to_many :statuses

  before_create :generate_number

  def to_s
    id.to_s
  end

  def generate_number
    self.number = ((0..9).to_a + ('a'..'z').to_a + ('A'..'Z').to_a).shuffle.first(16).join
    self.statuses << Status.active.where(inited: true).first
  end
end
