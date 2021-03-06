# frozen_string_literal: true

#
# User Model
# ============
class User < ApplicationRecord
  extend FriendlyId
  friendly_id :username, use: [:slugged, :finders]

  # Concerns
  include Users::RegisterActivable
  include Assets::Avatarable
  include OptionalModules::Omniauthable

  # Helpers
  include AssetsHelper

  # Accessors
  attr_accessor :login

  # Include default devise modules. Others available are:
  # :registerable, :confirmable, :lockable, :timeoutable and :omniauthable
  devise :database_authenticatable,
         :recoverable, :rememberable, :trackable, :validatable

  # Model relations
  has_many :posts, dependent: :destroy
  has_many :blogs, dependent: :destroy
  belongs_to :role
  accepts_nested_attributes_for :role, reject_if: :all_blank

  # Validation rules
  validates :username,
            presence: true,
            uniqueness: {
              case_sensitive: false,
              scope: :provider
            },
            format: { with: /\A[a-z0-9 _\-\.]*\z/i },
            if: proc { |u| u.new_record? || u.username_changed? }

  validates :email,
            presence: true,
            email_format: true,
            uniqueness: {
              case_sensitive: false,
              scope: :provider
            }

  # Delegates
  delegate :name, to: :role, prefix: true, allow_nil: true

  # Scopes
  scope :except_super_administrator, -> { where.not(role_id: 1) }

  # define has_role? methods
  %w(super_administrator administrator subscriber).each do |role|
    define_method(:"#{role}?") do
      role_name == role
    end
  end

  def should_generate_new_friendly_id?
    username_changed? || super
  end

  # Access current_user in model
  def self.current_user
    Thread.current[:current_user]
  end

  def self.current_user=(user)
    Thread.current[:current_user] = user
  end

  # Connect user by username or email
  # rubocop:disable Rails/FindBy
  def self.find_for_database_authentication(warden_conditions)
    conditions = warden_conditions.dup
    if (login = conditions.delete(:login))
      where(conditions.to_hash).where('lower(username) = :value OR lower(email) = :value', value: login.downcase).first

    else
      where(conditions.to_hash).first
    end
  end
  # rubocop:enable Rails/FindBy
end

# == Schema Information
#
# Table name: users
#
#  id                     :integer          not null, primary key
#  email                  :string(255)      default(""), not null
#  username               :string(255)
#  slug                   :string(255)
#  encrypted_password     :string(255)      default(""), not null
#  role_id                :integer          default(3), not null
#  reset_password_token   :string(255)
#  reset_password_sent_at :datetime
#  remember_created_at    :datetime
#  sign_in_count          :integer          default(0), not null
#  current_sign_in_at     :datetime
#  last_sign_in_at        :datetime
#  current_sign_in_ip     :string(255)
#  last_sign_in_ip        :string(255)
#  created_at             :datetime         not null
#  updated_at             :datetime         not null
#  avatar_file_name       :string(255)
#  retina_dimensions      :text(65535)
#  avatar_content_type    :string(255)
#  avatar_file_size       :integer
#  avatar_updated_at      :datetime
#  provider               :string(255)
#  uid                    :string(255)
#  account_active         :boolean          default(FALSE)
#
# Indexes
#
#  index_users_on_email                 (email) UNIQUE
#  index_users_on_reset_password_token  (reset_password_token) UNIQUE
#  index_users_on_role_id               (role_id)
#  index_users_on_slug                  (slug)
#
