class Tour < ApplicationRecord

  CURRENCIES = %w(CHF EUR)

  # TODO: add new start & end date fields - sort on them (queried from bookings)
  # TODO: distinct for uniq returns - find an better solution - add back sorting

  after_touch do
    dates = self.booking_dates.to_a
    has_dates = dates.empty?

    new_start_date = if has_dates then nil else dates.first.day end
    self.update tour_start_date: new_start_date unless tour_start_date == new_start_date

    new_end_date = if has_dates then nil else dates.last.day end
    self.update tour_end_date: new_end_date unless tour_end_date == new_end_date
  end

  belongs_to :creator, foreign_key: "company_id", class_name: "Company", optional: true

  has_many :awards,   inverse_of: :tour, dependent: :destroy
  has_many :comments, inverse_of: :tour, dependent: :destroy
  has_many :booking_dates, -> { order(day: :asc) }, inverse_of: :tour, dependent: :destroy
  has_many :companies,     through: :booking_dates

  # https://evilmartians.com/chronicles/rails-5-2-active-storage-and-beyond
  has_one_attached :cover_image
  has_one_attached :tech_sheet
  # has_many_attached :carosel_images

  # Use EUR as the model level currency
  register_currency :eur

  monetize :price_braaam_cents, numericality: { greater_than_or_equal_to: 0 }
  monetize :price_normal_cents, numericality: { greater_than_or_equal_to: 0 }

  accepts_nested_attributes_for :awards,
                          reject_if: :all_blank, allow_destroy: true
  accepts_nested_attributes_for :booking_dates,
                          reject_if: :all_blank, allow_destroy: true
  accepts_nested_attributes_for :comments,
                          reject_if: :all_blank, allow_destroy: true

  validates :tour_caption,  presence: true, length: { minimum: 2 }
  validates :tour_artist_name, presence: true, length: { minimum: 2 }
  validates :title,       presence: true, length: { minimum: 2 }
  validates :description, presence: true, length: { minimum: 2 }
  # validate url
  validates :video_uri,   allow_blank: true,
                          format: { with: /\Ahttps?:\/\/[\S.-]+\.[\S.-]+\z/i,
                                    message: "please enter a valid url" }
  validates :housing,     inclusion: { in: [ true, false ] }
  validates :catering,    inclusion: { in: [ true, false ] }

  validates :tour_artist_email, presence: true, length: { minimum: 6 }
  validates :tour_staff_number, presence: true, numericality: { only_integer: true, greater_than_or_equal_to: 0 }

  validates :tour_start_date, presence: true, if: :has_booking_days?
  validates :tour_end_date, presence: true, if: :has_booking_days?

  default_scope      { with_attached_cover_image }
  scope :future,  -> { after(Date.today) }
  scope :past,    -> { before(Date.today) }
  scope :current, -> { after(Date.today - 1) }
  scope :index_collection, -> { current.distinct.with_image }
  scope :show_collection, -> (id){ current.with_image.where.not(id: id) }
  scope :with_image, -> { joins("INNER JOIN active_storage_attachments ON active_storage_attachments.record_id = tours.id AND active_storage_attachments.record_type = 'Tour'") }

  scope :after,  -> (date) { where('tour_start_date > ? OR tour_end_date > ?', date, date).order(:tour_start_date).order(:title) }
  scope :before, -> (date) { where('tour_start_date < ? OR tour_end_date < ?', date, date).order(:tour_start_date).order(:title) }

  scope :summer, -> { where('tour_start_date >= ? and tour_start_date <= ?', Date.strptime(ApplicationController.helpers.summer_dates.first, "%d-%b-%y"), Date.strptime(ApplicationController.helpers.summer_dates.last, "%d-%b-%y")) }
  scope :winter, -> { where('tour_start_date >= ? and tour_start_date <= ?', Date.strptime(ApplicationController.helpers.winter_dates.first, "%d-%b-%y"), Date.strptime(ApplicationController.helpers.winter_dates.last, "%d-%b-%y")) }

  scope :highlighted, -> { limit(3).where.not(highlighted_at: '').order(highlighted_at: :desc) }

  def booked_days_count
    self.booking_dates.where.not(company_id: nil).count
  end

  def need_tech_help?
    self.tech_sheet.attached?
  end

  def title_with_country
    "#{title} (#{artist_country})"
  end

  def creator_name
     return "Braaam" if creator.blank?
     return creator.name
  end

  def braaam_tour?
    creator.blank?
  end

  def has_booking_days?
    !(self.booking_dates.pluck(:id).blank?)
  end

  def status(args = {format: :text})
    case args[:format]
    when :number
      return 4 if highlighted_at.present? and not Tour.highlighted.pluck(:id).include? id
      return 1 if highlighted_at.present?
      return 2 if tour_start_date.present? and tour_start_date <= Date.today and tour_end_date >= Date.today
      return 3 if tour_start_date.present? and tour_start_date > Date.today
      return 5 if tour_end_date.present? and tour_end_date < Date.today
      return 6 # catch nil status and put it at the end
    when :text
      return I18n.t("activerecord.attributes.tour.statuses.old_highlight") if highlighted_at.present? and not Tour.highlighted.pluck(:id).include? id
      return I18n.t("activerecord.attributes.tour.statuses.highlight") if highlighted_at.present?
      return I18n.t("activerecord.attributes.tour.statuses.current") if tour_start_date.present? and tour_start_date <= Date.today and tour_end_date >= Date.today
      return I18n.t("activerecord.attributes.tour.statuses.future") if tour_start_date.present? and tour_start_date > Date.today
      return I18n.t("activerecord.attributes.tour.statuses.past") if tour_end_date.present? and tour_end_date < Date.today
    end
  end

  def highlighted?
    highlighted_at.present? and Tour.highlighted.pluck(:id).include? id
  end

  def season
    return nil unless has_booking_days?
    infos = { year: self.tour_start_date.year.to_s }
    infos[:season] = "summer" if self.summer_tour?
    infos[:season] = "winter" if self.winter_tour?
    return infos
  end

  def summer_tour?
    return false unless has_booking_days?
    self.tour_start_date >= Date.strptime(ApplicationController.helpers.summer_dates.first, "%d-%b-%y") and self.tour_start_date <= Date.strptime(ApplicationController.helpers.summer_dates.last, "%d-%b-%y")
  end

  def winter_tour?
    return false unless has_booking_days?
    self.tour_start_date >= Date.strptime(ApplicationController.helpers.winter_dates.first, "%d-%b-%y") and self.tour_start_date <= Date.strptime(ApplicationController.helpers.winter_dates.last, "%d-%b-%y")
  end
end
