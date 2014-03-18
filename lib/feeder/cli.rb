require 'yell'
require 'singleton'

module Feeder
  class CLI
    include Singleton

    Yell.new name: Object do |l|
      l.adapter STDOUT, level: [:debug, :error, :warn, :fatal]
      l.adapter :file, 'feed.log', level: [:info], format: Yell.format( '%d: %m', '%Y-%m-%d %H:%M')
    end
    Object.send :include, Yell::Loggable

    def run
      logger.debug 'starting feeder .. Ada is waiting for feed'

      @config = Configuration.instance
      gmail_credentials = @config.gmail_credentials
      @gmail = GmailWrapper.new(gmail_credentials[:login], gmail_credentials[:password])
      @rpi = RaspberryPi.new

      while true
        @gmail.login
        @gmail.check_mail.each do |mail|
          if mail[:subject] =~ /Feed/
            logger.info "#{mail[:sender]} fed her."
            logger.debug "Ada got fed by #{mail[:sender]}."
            @rpi.rotate_motor
            @gmail.send_gratitudes(
                receiver: mail[:sender],
                sender_address: 'ada.goes.pi@gmail.com',
                sender_name: 'Ada',
                attachment: 'resources/ada.gif'
            )
          end
        end
        @gmail.logout
        sleep(1)
      end
    end
  end
end