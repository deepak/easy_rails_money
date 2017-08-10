class ExchangeRate < ActiveRecord::Base
  validates :from_currency, :inclusion => { in: Currency::VALUES-['inr'], :message => "%{value} is not supported to have a ExchangeRate" }
  validates :to_currency, :inclusion => { in: ['inr'], :message => "%{value} is not supported to have a ExchangeRate"  }
  validates :value, :numericality => {:greater_than => 0}, presence:true
  validates :from_date, presence: true
  validate :check_date_format
  validate :check_date_range
  scope :at, ->(dt) { where('from_date <= ? and (to_date >= ? or to_date is null)', dt, dt) }

  after_save :set_exchange_rate_expiry

  attr_accessible  :from_date, :to_date, :from_currency, :to_currency, :value, :as => [:admin]
  attr_accessor :sgd_to_inr, :usd_to_inr

  def self.exchange_rate_in_json_at(date)
    build_bank_for(date).export_rates(:json)
  end

  def self.build_bank_for(date)
    bank = Money::Bank::VariableExchange.new
    exchange_rates = ExchangeRate.at(date).order('to_date')
    exchange_rates.each do |exchange_rate|
      bank.set_rate exchange_rate.from_currency, exchange_rate.to_currency, exchange_rate.value.to_s
      bank.set_rate exchange_rate.to_currency, exchange_rate.from_currency, (1.0 / exchange_rate.value).to_s
    end
    bank
  end

  def set_exchange_rate_expiry
    if self.from_date <= Time.now
      Money.build_default_bank
    end
  end

  def to_s
    "1 #{from_currency.try(:upcase)} = #{value} #{to_currency.try(:upcase)}"
  end

  private

  def check_date_range
    errors['from_date'] << "cant be greater than to_date" if to_date.presence && from_date > to_date
  end

  # from_date is mandatory; to_date can be nil
  def check_date_format
    err = "is not valid date."
    errors["from_date"] << err unless is_date(from_date)
    errors["to_date"] << err if(to_date.present? && !is_date(to_date))
  end

  def is_date(dt)
    dt.is_a?(Date) || dt.is_a?(ActiveSupport::TimeWithZone)
  end
end
