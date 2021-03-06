# frozen_string_literal: true

#
# == SocialDecorator
#
class SocialDecorator < ApplicationDecorator
  include Draper::LazyHelpers
  delegate_all

  #
  # == Content
  #
  def kind
    I18n.t("social.#{model.kind}")
  end

  def link
    link_to model.link, model.link, target: :_blank if link?
  end

  #
  # == Ikons
  #
  def ikon_deco(size = '1x')
    if ikon?
      retina_image_tag model, :ikon, :small
    elsif font_ikon?
      fa_icon "#{model.font_ikon} #{size}"
    else
      model.title
    end
  end

  def hint_by_ikon
    if ikon?
      t('formtastic.hints.social.already_picture')
    else
      safe_join [raw(t('formtastic.hints.social.default_hint', list: font_ikon_list))]
    end
  end

  def ikon?
    model.ikon.present? && model.ikon.exists?
  end

  private

  def font_ikon_list
    Social.allowed_font_awesome_ikons.map { |ikon| h.fa_icon(ikon, title: ikon) }.join(', ')
  end
end
