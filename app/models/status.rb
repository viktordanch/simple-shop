class Status < ActiveRecord::Base
  has_and_belongs_to_many :orders

  scope :active, -> { where(active: true) }
end
