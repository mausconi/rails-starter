# frozen_string_literal: true

#
# == Module OptionalModules
#
module OptionalModules
  #
  # == Module Assets
  #
  module Assets
    #
    # == Imageable Concerns
    #
    module Imageable
      extend ActiveSupport::Concern
      include ApplicationHelper

      included do
        has_many :pictures, -> { order(:position) }, as: :attachable, dependent: :destroy
        accepts_nested_attributes_for :pictures, reject_if: :all_blank, allow_destroy: true

        has_one :picture, as: :attachable, dependent: :destroy
        accepts_nested_attributes_for :picture, reject_if: :all_blank, allow_destroy: true

        delegate :title, :description, :online, to: :picture, prefix: true, allow_nil: true
        delegate :online, to: :pictures, prefix: true, allow_nil: true
      end

      #
      # == Pictures
      #
      # Return first object model when :has_many relation
      def first_pictures
        pictures.online.first if pictures?
      end

      # Return first paperclip object when :has_many relation
      def first_pictures_image
        pictures.online.first.image if pictures?
      end

      # Return first paperclip object url by size when :has_many relation
      def first_picture_image_url_by_size(size)
        first_pictures_image.url(size) if pictures?
      end

      # Return paperclip object url by size when :has_one relation
      def image_url_by_size(size)
        picture.image.url(size) if picture?
      end

      def picture?
        picture.present? && picture.image.exists? && picture.online?
      end

      def pictures?
        pictures.online.any? && pictures.online.last.image.exists?
      end
    end
  end
end
