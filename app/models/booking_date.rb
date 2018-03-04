class BookingDate < ApplicationRecord

  belongs_to :tour
  belongs_to :company, optional: true

  validates :tour, uniqueness: { scope: :day,
                                message: 'tours may only have one event per-day'
                              }
  validates_date :day,:on => :update
  validates_date :day,:on => :create,
                      :on_or_after => :today,
                      :on_or_after_message => 'must be a date on or after today'

  # https://ducktypelabs.com/using-scope-with-associations/
  # default_scope     { where('day >= ?', Date.today) }
  scope :future, -> { after(Date.today) }
  scope :past,   -> { before(Date.today) }
  # scope :future, -> { where('day >= ?', Date.today) }
  # scope :past,   -> { where('day < ?',  Date.today) }
  scope :after,  -> (date) { where('day >= ?', date).order(day: :asc) }
  scope :before, -> (date) { where('day < ?', date).order(day: :desc) }

end
