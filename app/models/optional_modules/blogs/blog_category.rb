# frozen_string_literal: true

# == Schema Information
#
# Table name: blog_categories
#
#  id          :integer          not null, primary key
#  name        :string(255)      default("")
#  slug        :string(255)      default("")
#  blogs_count :integer          default(0), not null
#  created_at  :datetime         not null
#  updated_at  :datetime         not null
#

#
# == BlogCategory Model
#
class BlogCategory < ActiveRecord::Base
  translates :name, :slug
  active_admin_translates :name, :slug do
    validates :name,
              uniqueness: true,
              presence: true
  end

  extend FriendlyId
  friendly_id :slug_candidates, use: [:slugged, :history, :globalize, :finders]

  has_many :blogs, dependent: :destroy, inverse_of: :blog_category

  private

  def slug_candidates
    [:name, [:name, :deduced_id]]
  end

  def deduced_id
    self.class.where(name: name).count + 1
  end
end
