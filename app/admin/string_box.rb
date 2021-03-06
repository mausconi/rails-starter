# frozen_string_literal: true
ActiveAdmin.register StringBox do
  menu parent: I18n.t('admin_menu.config')
  includes :translations, :optional_module

  permit_params do
    params = [:id, :key]
    params.push(*post_attributes)
    params.push :optional_module_id if current_user.super_administrator?
    params
  end

  decorate_with StringBoxDecorator
  config.clear_sidebar_sections!

  index do
    column :key if current_user.super_administrator?
    column :description
    column :title
    column :content

    translation_status
    actions
  end

  show title: :title_aa_show do
    arbre_cache(self, resource.cache_key) do
      attributes_table do
        row :key if current_user.super_administrator?
        row :description
        row :title
        row :content
      end
    end
  end

  form do |f|
    f.semantic_errors(*f.object.errors.keys)

    if f.object.description?
      f.columns do
        f.column do
          f.inputs t('activerecord.attributes.string_box.description') do
            content_tag(:li) do
              concat content_tag(:p, f.object.description)
            end
          end
        end # column
      end # columns
    end # if

    f.columns do
      f.column do
        f.inputs t('formtastic.titles.string_box_details') do
          f.translated_inputs 'Translated fields', switch_locale: false do |t|
            t.input :title
            t.input :content,
                    input_html: { class: 'froala' }
          end
        end
      end
    end

    if current_user.super_administrator?
      f.columns do
        f.column do
          f.inputs do
            if f.object.new_record?
              f.input :key
            else
              f.input :key, input_html: { disabled: :disabled }
            end

            f.input :optional_module_id,
                    as: :select,
                    collection: OptionalModule.all.map { |m| [m.decorate.name, m.id] },
                    include_blank: true
          end
        end # column
      end # columns
    end # if

    f.actions
  end

  #
  # == Controller
  #
  controller do
    include ActiveAdmin::ParamsHelper
    include Skippable
  end
end
