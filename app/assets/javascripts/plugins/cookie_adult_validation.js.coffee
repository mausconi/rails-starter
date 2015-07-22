$(document).on 'ready page:load page:restore', ->
  if gon.adult_validation is true and Cookies.get('adult') is undefined
    vex.dialog.confirm
      message: gon.adult_not_validated_popup_content
      callback: (value) ->
        window.location.href = 'http://google.fr' if value is false
        Cookies.set('adult', 'validated') if value is true