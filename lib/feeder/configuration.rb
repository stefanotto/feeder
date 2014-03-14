require 'configliere'
require 'yaml'
require 'singleton'

module Feeder
  class Configuration
    include Singleton

    CONFIG_FILE_LOCATION = File.join(Dir.home, '.feeder/')
    CONFIG_FILE_NAME  = 'feeder_conf.yml'
    CONFIG_FILE = File.join(CONFIG_FILE_LOCATION, CONFIG_FILE_NAME)

    def initialize
      Settings.use :config_file, :encrypted
      Settings.define 'gmail.login'
      Settings.define 'gmail.password', encrypted: true
      Settings[:encrypt_pass] = ENV['ENCRYPT_PASS']
      if Settings[:encrypt_pass].nil?
        puts "Missing config decryption password!\n\nUse: export ENCRYPT_PASS='your_password'"
        exit
      end
      read_settings!
    end

    def create_config_file(gmail_login, gmail_password)
      Settings({
                   gmail: {
                       login: gmail_login,
                       password: gmail_password
                   }
               })
      Settings.save! CONFIG_FILE
    end

    def read_settings!
      Settings.read(CONFIG_FILE)
      Settings.resolve!
    rescue OpenSSL::Cipher::CipherError
      puts 'Wrong config decryption password!'
    end

    def gmail_credentials
      {
        login: Settings[:gmail][:login],
        password: Settings[:gmail][:password]
      }
    end

    private :read_settings!

  end
end

