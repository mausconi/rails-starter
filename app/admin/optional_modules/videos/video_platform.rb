# frozen_string_literal: true
ActiveAdmin.register VideoPlatform do
  menu parent: I18n.t('admin_menu.assets')
  includes :videoable

  permit_params :id,
                :url,
                :native_informations,
                :online,
                translations_attributes: [
                  :id, :locale, :title, :description
                ]

  decorate_with VideoPlatformDecorator
  config.clear_sidebar_sections!

  batch_action :toggle_online, if: proc { can? :toggle_online, VideoPlatform } do |ids|
    VideoPlatform.find(ids).each { |item| item.toggle! :online }
    redirect_back(fallback_location: admin_dashboard_path, notice: t('active_admin.batch_actions.flash'))
  end

  index do
    selectable_column
    column :preview
    column :video_link
    column :from_article
    bool_column :online

    actions
  end

  show do
    arbre_cache(self, resource.cache_key) do
      columns do
        column do
          attributes_table do
            row :preview
            row :video_link
            row :from_article
            bool_row :online
          end
        end

        column do
          attributes_table do
            bool_row :native_informations
            row :title_d
            row :description_d
          end
        end
      end
    end
  end

  form do |f|
    f.semantic_errors(*f.object.errors.keys)

    columns do
      column do
        f.inputs t('formtastic.titles.video_platform_details') do
          f.input :url,
                  hint: "#{t('formtastic.hints.video_platform.url')} <br /><br /> #{f.object.decorate.preview}"

          f.input :online
        end
      end

      column do
        f.inputs t('formtastic.titles.video_content_details') do
          f.input :native_informations

          f.translated_inputs 'Translated fields', switch_locale: true do |t|
            t.input :title,
                    hint: I18n.t('formtastic.hints.video_platform.title')
            t.input :description,
                    hint: I18n.t('formtastic.hints.video_platform.description'),
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
    def scoped_collection
      super.includes videoable: [:translations]
    end

    def edit
      @page_title = "#{t('active_admin.edit')} #{I18n.t('activerecord.models.video_platform.one')} article \"#{resource.decorate.from_article.title}\""
    end
  end
end
