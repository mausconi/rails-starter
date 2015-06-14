#
# == Newsletter Mailer
#
class NewsletterMailer < ActionMailer::Base
  add_template_helper(HtmlHelper)
  default from: Setting.first.email

  def welcome_user(newsletter_user)
    @newsletter_user = newsletter_user
    @newsletter_user.name = @newsletter_user.email.split('@').first
    @title = t('newsletter.welcome')
    @host = Figaro.env.application_host
    @is_welcome_user = true

    mail(to: @newsletter_user.email, subject: @title) do |format|
      format.html { render layout: 'newsletter' }
      format.text
    end
  end

  def send_newsletter(newsletter_user, newsletter)
    @newsletter_user = newsletter_user
    @newsletter = newsletter
    @title = @newsletter.title
    @host = Figaro.env.application_host
    mail(to: @newsletter_user.email, subject: @newsletter.title) do |format|
      format.html { render layout: 'newsletter' }
      format.text
    end
  end
end
