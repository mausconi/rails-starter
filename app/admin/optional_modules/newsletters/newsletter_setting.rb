# frozen_string_literal: true
ActiveAdmin.register NewsletterSetting do
  menu parent: I18n.t('admin_menu.modules_config')

  permit_params :id,
                :send_welcome_email,
                :title_subscriber,
                :content_subscriber,
                newsletter_user_roles_attributes: [
                  :id,
                  translations_attributes: [
                    :id, :locale, :title
                  ]
                ]

  decorate_with NewsletterSettingDecorator
  config.clear_sidebar_sections!

  show title: I18n.t('activerecord.models.newsletter_setting.one') do
    arbre_cache(self, resource.cache_key) do
      columns do
        column do
          attributes_table do
            bool_row :send_welcome_email
            list_row :newsletter_user_roles_list, list_type: :ul
          end
        end

        if resource.send_welcome_email?
          column do
            panel I18n.t('newsletter.active_admin.welcome_panel_title') do
              attributes_table_for resource.decorate do
                row :title_subscriber
                row :content_subscriber
              end
            end
          end # columns
        end # if
      end # columns
    end
  end

  form do |f|
    f.semantic_errors(*f.object.errors.keys)

    columns do
      column do
        f.inputs t('formtastic.titles.newsletter_setting_details') do
          f.input :send_welcome_email
        end
      end
    end

    columns do
      column do
        render 'admin/newsletter_user_roles/form', f: f
      end
    end

    columns id: 'newsletter_config_form' do
      column do
        f.inputs t('formtastic.titles.newsletter_setting_content') do
          f.translated_inputs 'Translated fields', switch_locale: true do |t|
            t.input :title_subscriber, label: true
            t.input :content_subscriber,
                    input_html: { class: 'froala' }
          end
        end
      end
    end

    f.actions
  end

  #
  # == Controller
  #
  controller do
    before_action :redirect_to_show, only: [:index], if: proc { current_user_and_administrator? && @newsletter_module.enabled? }

    def scoped_collection
      super.includes newsletter_user_roles: [:translations]
    end

    private

    def redirect_to_show
      redirect_to admin_newsletter_setting_path(NewsletterSetting.first)
    end
  end
end
