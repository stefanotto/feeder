require 'gmail'

module Feeder
  class GmailWrapper

    def initialize(login, password)
      @login = login
      @password = password
    end

    def check_mail
      logger.debug "Checking mail now [#{Time.now}]."

      mails = []
      @gmail.peek = true
      @gmail.inbox.emails(:unread).each do |mail|
        mails << {
          sender: mail.from.first,
          subject: mail.subject,
        }
        mail.mark(:read)
        mail.archive!
      end
      mails
    rescue Net::IMAP::NoResponseError
      puts "Your Gmail credentials are incorrect!"
      puts "Run feeder with '--setup_credentials'"
      exit
    end

    def send_gratitudes(options = {})
      sender_address = options.fetch(:sender_address)
      sender_name = options.fetch(:sender_name)
      receiver = options.fetch(:receiver)
      subject_str  = options.fetch(:subject_str, "Thanks!")
      message  = options.fetch(:message, "")
      attachment = options.fetch(:attachment, nil)

      logger.debug "sending gratitudes to #{receiver} ..."

      @gmail.deliver do
        from "#{sender_name} <#{sender_address}>"
        to receiver
        subject subject_str
        text_part { body message }
        add_file attachment if attachment
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