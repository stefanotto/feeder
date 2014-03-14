require 'gmail'

module Feeder
  class GmailWatch

    def initialize(login, password)
      @login = login
      @password = password
    end

    def check_mail
      logger.debug "Checking mail now [#{Time.now}]."

      got_fed = false
      @gmail.peek = true
      @gmail.inbox.emails(:unread).each do |mail|
        if mail.subject =~ /Lass es dir schmecken/
          logger.info "#{mail.from} fed her."
          logger.debug "Ada got fed by #{mail.from}."
          send_gratitudes receiver: mail.from, message: "Danke! :)"
          mail.mark(:read)
          mail.archive!
          got_fed = true
        end
      end
      got_fed
    rescue Net::IMAP::NoResponseError
      puts "Your Gmail credentials are incorrect!"
      puts "Run feeder with '--setup_credentials'"
      exit
    end

    def send_gratitudes(options = {})
      receiver = options.fetch(:receiver)
      subject_str  = options.fetch(:subject_str, "Danke!")
      message  = options.fetch(:message, "")

      logger.debug "sending gratitudes to #{receiver} ..."

      @gmail.deliver do
        from 'Ada <ada.goes.pi@gmail.com>'
        to receiver
        subject subject_str
        text_part { body message }
        add_file "resources/ada.gif"
      end
      logger.debug "... mail sent"
    end

    def login
      @gmail = Gmail.new(@login, @password)
    end

    def logout
      @gmail.logout
    end
  end
end