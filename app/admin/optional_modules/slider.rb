ActiveAdmin.register Slider do
  menu parent: I18n.t('admin_menu.modules')
  includes :category

  permit_params :id,
                :animate,
                :autoplay,
                :time_to_show,
                :hover_pause,
                :looper,
                :navigation,
                :bullet,
                :online,
                :category_id,
                slides_attributes: [
                  :id, :image, :online, :_destroy,
                  translations_attributes: [
                    :id, :locale, :title, :description
                  ]
                ]

  decorate_with SliderDecorator
  config.clear_sidebar_sections!

  batch_action :toggle_value do |ids|
    Slider.find(ids).each do |slider|
      toggle_value = slider.online? ? false : true
      slider.update_attribute(:online, toggle_value)
    end
    redirect_to :back, notice: t('active_admin.batch_actions.flash')
  end

  index do
    selectable_column
    column :page
    column :autoplay_deco
    column :hover_pause_deco
    column :loop_deco
    column :navigation_deco
    column :bullet_deco
    column :time_to_show_deco
    column :animate
    column :status

    actions
  end

  show title: :title_aa_show do
    columns do
      column do
        attributes_table do
          row :page
          row :status
          row :autoplay_deco
          row :hover_pause_deco
          row :loop_deco
          row :navigation_deco
          row :bullet_deco
          row :time_to_show_deco
          row :animate
        end
      end

      column do
      end
    end

    # panel 'Slider preview' do
    #   render 'optional_modules/sliders/show', slider: resource, force: true
    # end
  end

  form do |f|
    f.semantic_errors(*f.object.errors.keys)

    columns do
      column do
        f.inputs t('activerecord.models.slider.one') do
          f.input :autoplay,
                  hint: I18n.t('form.hint.slider.autoplay')
          f.input :hover_pause,
                  hint: I18n.t('form.hint.slider.hover_pause')
          f.input :looper,
                  as: :boolean,
                  hint: I18n.t('form.hint.slider.loop')
          f.input :navigation,
                  hint: I18n.t('form.hint.slider.navigation')
          f.input :bullet,
                  hint: I18n.t('form.hint.slider.bullet')
          f.input :time_to_show,
                  hint: I18n.t('form.hint.slider.time_to_show')
          f.input :animate,
                  collection: %w( fade horizontal vertical ),
                  include_blank: false,
                  hint: I18n.t('form.hint.slider.animate')
        end
      end

      column do
        f.inputs t('additional') do
          f.input :category_id,
                  as: :select,
                  collection: Category.visible_header,
                  include_blank: false,
                  input_html: { class: 'chosen-select' }
          f.input :online
        end
      end
    end

    render 'admin/slides/many', f: f

    f.actions
  end
end
