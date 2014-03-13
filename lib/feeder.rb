require 'yell'
require 'singleton'

require 'feeder/gmail_watch.rb'
require 'feeder/raspberry_pi.rb'

module Feeder
  class CLI
    include Singleton

    Yell.new name: Object do |l|
      l.adapter STDOUT, level: [:debug, :error, :warn, :fatal]
      l.adapter :file, 'feed.log', level: [:info], format: Yell.format( "%d: %m", "%Y-%m-%d %H:%M" )
    end
    Object.send :include, Yell::Loggable

    def run
      logger.debug "starting feeder .. Ada is waiting for feed"
      @gmail = GmailWatch.new
      @rpi = RaspberryPi.new

      while true
        @gmail.login
        @rpi.rotate_motor if @gmail.check_mail
        @gmail.logout
        sleep(1)
      end
    end

  end

end

