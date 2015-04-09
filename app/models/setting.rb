# == Schema Information
#
# Table name: settings
#
#  id              :integer          not null, primary key
#  name            :string(255)
#  title           :string(255)
#  subtitle        :string(255)
#  phone           :string(255)
#  email           :string(255)
#  address         :string(255)
#  city            :string(255)
#  postcode        :string(255)
#  geocode_address :string(255)
#  latitude        :float(24)
#  longitude       :float(24)
#  show_map        :boolean          default(TRUE)
#  created_at      :datetime
#  updated_at      :datetime
#

#
# == Setting Model
#
class Setting < ActiveRecord::Base
  translates :title, :subtitle, fallbacks_for_empty_translations: true
  active_admin_translates :title, :subtitle do
    validates :title, presence: true
  end

  validates :name,     presence: true
  validates :address,  presence: true
  validates :city,     presence: true
  validates :postcode, presence: true, numericality: { only_integer: true }
  validates :email,    presence: true, email_format: {}

  def title_and_subtitle
    return "#{title}, #{subtitle}" if subtitle?
    title
  end

  def subtitle?
    !subtitle.blank?
  end
end
