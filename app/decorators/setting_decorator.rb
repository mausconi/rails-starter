#
# == Setting Decorator
#
class SettingDecorator < ApplicationDecorator
  include Draper::LazyHelpers
  delegate_all

  def title_subtitle(header = :h1, link = root_path, klass = '')
    h.content_tag(:a, href: link, class: "l-header-site-title-link #{klass}") do
      concat(h.content_tag(header, class: 'l-header-site-title') do
        concat(model.title) + concat(subtitle)
      end)
    end
  end

  def full_address
    simple_format("#{model.address} <br> #{model.postcode} - #{model.city}")
  end

  def latlon
    simple_format("#{model.latitude}, #{model.longitude}")
  end

  def credentials
    "#{setting.name} - #{copyright} <br> Copyright &copy; #{current_year} <br> #{about} #{admin_link}"
  end

  def map(force = false)
    raw content_tag(:div, nil, class: 'map dark', id: 'map') if model.show_map || force
  end

  def newsletter(newsletter_user)
    content_tag(:div) do
      concat(content_tag(:span, I18n.t('newsletter.header'), class: 'header'))
      concat(render 'footer/newsletter_form', newsletter_user: newsletter_user)
    end
  end

  private

  def about
    link_to I18n.t('main_menu.about'), abouts_path
  end

  def copyright
    I18n.t('footer.copyright')
  end

  def admin_link
    ' - ' + (link_to ' administration', admin_root_path, target: :blank) if current_user_and_administrator?
  end

  def subtitle
    h.content_tag(:small, model.subtitle, class: 'l-header-site-subtitle')
  end
end
