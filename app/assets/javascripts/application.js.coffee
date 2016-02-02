#= require vendor/modernizr
#= require jquery
#= require jquery_ujs
#= require jquery-ui/autocomplete
#= require foundation/foundation
#= require foundation
#= require plugins/foundation_init
#= require turbolinks
#= require nprogress
#= require nprogress-turbolinks
#= require rails.validations
#= require rails.validations.simple_form
#= require rails.validations.simple_form.fix
#= require i18n
#= require i18n/translations
#= require js.cookie
#= require vex.combined.min.js
#= require plugins/vex_config
#= require plugins/override_rails_confirm
#= require classes/social_share_class
#= require mapbox
#= require plugins/mapbox
#= require magnific-popup
#= require fotorama
#= require moment
#= require fullcalendar
#= require fullcalendar/lang/fr
#= require jquery.autosize
#= require jquery.autosize.initializer
#= require globals/_functions
#= require modules/responsive_menu
#= require modules/autocomplete_search
#= require plugins/nprogress
#= require plugins/cookie_ie
#= require plugins/cookie_adult_validation
#= require plugins/fotorama
#= require plugins/fullcalendar
#= require base/flash
#= require outdatedbrowser/outdatedBrowser
#= require outdated_browser
#= require mediaelement_rails
#= require mediaelement/mejs-feature-logo.min
#= require plugins/mediaelement
#= require plugins/cookie_cnil

$(document).on 'ready page:load page:restore', ->
  $('.magnific-popup').magnificPopup
    type: 'image'
    # image:
    #   titleSrc: (item) ->
    #     return item.el.attr('title')

  # Add loader after submiting comment form
  $('form button[type="submit"]').on 'click', (e) ->
    $this = $(this)

    window.ClientSideValidations.callbacks.form.pass = ($element, callback) ->
      $this.prev().fadeIn()
      $('form').resetClientSideValidations()


  # Scroll infinite for comments
  if $('.pagination').length
    $(window).on 'scroll', throttle(((e) ->
      url = $('.pagination .next a').attr('href')
      if url && $(window).scrollTop() > ($(document).height() - $(window).height() - 50)
        $('.pagination').text(I18n.t('scroll_infinite.fetch_nexts', { locale: gon.language }))
        $.getScript(url)
      return
    ), 100)
    $(window).scroll()