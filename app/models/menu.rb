# == Schema Information
#
# Table name: menus
#
#  id             :integer          not null, primary key
#  title          :string(255)
#  online         :boolean          default(TRUE)
#  show_in_footer :boolean          default(FALSE)
#  ancestry       :string(255)
#  created_at     :datetime         not null
#  updated_at     :datetime         not null
#

#
# == Menu Model (parent)
#
class Menu < ActiveRecord::Base
  translates :title, fallbacks_for_empty_translations: true
  active_admin_translates :title

  has_ancestry

  scope :not_submenus, -> { where(ancestry: nil) }
  scope :online, -> { where(online: true) }

  def self.except_current_and_submenus(myself = nil)
    menus = []
    Menu.includes(:translations).not_submenus.each do |menu|
      menus << menu if menu != myself
    end
    menus
  end

  # validates :ancestry,
  #           presence: false,
  #           allow_blank: true,
  #           inclusion: { in: except_current_and_submenus }
end
