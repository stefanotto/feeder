#!/usr/bin/env ruby

require 'gli'
require 'yell'
require 'singleton'

module Feeder
  class CLI

    include Singleton
    include GLI::App

    def start
      program_desc 'Remotely feed you pet with your Raspberry Pi'

      desc 'Start the feed listener'
      command :start do |c|
        c.desc 'Describe a switch to run'
        c.switch :s

        c.desc 'Describe a flag to run'
        c.default_value 'default'
        c.flag :f
        c.action do |global_options,options,args|

        end
      end

      desc 'Describe config here'
      arg_name 'Describe arguments to config here'
      command :config do |c|
        c.action do |global_options,options,args|
          puts "config command ran"
        end
      end

      desc 'Describe user here'
      arg_name 'Describe arguments to user here'
      command :user do |c|
        c.action do |global_options,options,args|
          puts "user command ran"
        end
      end

      pre do |global,command,options,args|
        # Pre logic here
        # Return true to proceed; false to abort and not call the
        # chosen command
        # Use skips_pre before a command to skip this block
        # on that command only
        true
      end

      post do |global,command,options,args|
        # Post logic here
        # Use skips_post before a command to skip this
        # block on that command only
      end

      on_error do |exception|
        # Error logic here
        # return false to skip default error handling
        true
      end

      exit run(ARGV)
    end
=begin
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
          user = User.find_by_email mail[:sender]
          if user.nil?
            logger.info "unauthorized feeding by #{mail[:sender]}"
            break
          end
          if user.may_feed? mail[:subject]
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
=end
  end
end
