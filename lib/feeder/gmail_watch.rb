require 'gmail'

module Feeder
  class GmailWatch

    PASSWORD_FILE = 'config/passwd'
    def initialize
      read_login_data!
    end

    def read_login_data!
      File.open(PASSWORD_FILE, 'r') do |file|
        @gmail_login = file.readline.chomp
        @gmail_password = file.readline.chomp
      end
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
      @gmail = Gmail.new(@gmail_login, @gmail_password)
    end

    def logout
      @gmail.logout
    end
  end
end