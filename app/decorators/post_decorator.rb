#
# == PostDecorator
#
class PostDecorator < ApplicationDecorator
  include Draper::LazyHelpers
  include AssetsHelper

  delegate_all
  decorates_association :user

  #
  # == Author and avatar linked to Post
  #
  def author
    model.user_username
  end

  def link_author
    link_to author, admin_user_path(model.user)
  end

  def author_avatar
    user.image_avatar.html_safe
  end

  def author_with_avatar
    author_avatar + content_tag(:p, link_author)
  end

  #
  # == Post
  #
  def image
    if pictures?
      retina_image_tag first_pictures, :image, :small
    else
      'Pas d\'image'
    end
  end

  def content
    model.content.html_safe if content?
  end

  # Method used to display content in RSS Feed
  def image_and_content
    html = content
    html << image_tag(attachment_url(first_pictures.image, :medium)) if pictures?
    html
  end

  def title_front_link
    link = root_path
    link = send("#{model.type.downcase.underscore.singularize}_path", model) unless model.type == 'Home'
    link_to model.title, link, target: :_blank
  end

  def admin_link
    link = send("admin_#{model.type.downcase.underscore.singularize}_path", model)
    link_to I18n.t('active_admin.show'), link
  end

  # Type of Post
  #
  #
  def type_title
    Category.title_by_category(type)
  end
end
