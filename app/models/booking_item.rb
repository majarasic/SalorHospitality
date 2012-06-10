class BookingItem < ActiveRecord::Base
  attr_accessible :booking_id, :company_id, :guest_type_id, :hidden, :sum, :vendor_id, :surchargeslist, :base_price, :count
  include Scope
  belongs_to :booking
  belongs_to :vendor
  belongs_to :company
  belongs_to :guest_type
  has_many :surcharge_items

  serialize :taxes

  def surchargeslist=(ids)
    ids.delete '0' # 0 is sent by JS always, otherwise surchargeslist is not sent by ajax call
    self.surcharges = []
    ids.each do |i|
      self.surcharges << Surcharge.find_by_id(i.to_i)
    end
    self
  end

  def hide
    self.update_attribute :hidden, true
  end

  def calculate_totals
    self.base_price = RoomPrice.where(:season_id => self.booking.season_id, :room_type_id => self.booking.room.room_type_id, :guest_type_id => self.guest_type_id).first.base_price
    self.sum = self.count * (self.base_price + self.surcharges.sum(:amount))
    self.guest_type.taxes.each do |tax|
      tax_sum = (self.sum * ( tax.percent / 100.0 )).round(2)
      gro = (self.sum).round(2)
      net = (gro - tax_sum).round(2)
      self.taxes[tax.id] = {:percent => tax.percent, :tax => tax_sum, :gro => gro, :net => net, :letter => tax.letter, :name => tax.name }
    end
    self.hide if self.count.zero?
    save
  end
  
end
