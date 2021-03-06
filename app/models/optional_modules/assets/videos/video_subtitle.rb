# frozen_string_literal: true

#
# VideoSubtitle Model
# =====================
class VideoSubtitle < ApplicationRecord
  include Assets::Attachable

  # Constants
  ATTACHMENT_MAX_SIZE = 3 # megabytes
  ATTACHMENT_TYPES = [].freeze

  # Model relations
  belongs_to :subtitleable, polymorphic: true, touch: true

  handle_attachment :subtitle_fr
  handle_attachment :subtitle_en

  do_not_validate_attachment_file_type :subtitle_fr
  do_not_validate_attachment_file_type :subtitle_en

  include Assets::DeletableAttachment

  # Scopes
  scope :online, -> { where(online: true) }

  # subtitle_fr? // subtitle_en?
  I18n.available_locales.each do |locale|
    define_method "subtitle_#{locale}?" do
      send("subtitle_#{locale}").exists?
    end
  end
end

# == Schema Information
#
# Table name: video_subtitles
#
#  id                       :integer          not null, primary key
#  subtitleable_type        :string(255)
#  subtitleable_id          :integer
#  online                   :boolean          default(TRUE)
#  created_at               :datetime         not null
#  updated_at               :datetime         not null
#  subtitle_fr_file_name    :string(255)
#  subtitle_fr_content_type :string(255)
#  subtitle_fr_file_size    :integer
#  subtitle_fr_updated_at   :datetime
#  subtitle_en_file_name    :string(255)
#  subtitle_en_content_type :string(255)
#  subtitle_en_file_size    :integer
#  subtitle_en_updated_at   :datetime
#
# Indexes
#
#  index_video_subtitles_on_subtitleable_type_and_subtitleable_id  (subtitleable_type,subtitleable_id)
#
