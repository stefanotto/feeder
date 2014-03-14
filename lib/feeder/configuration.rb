require 'configliere'
require 'yaml'
require 'singleton'
require 'io/console'

module Feeder
  class Configuration
    include Singleton

    CONFIG_FILE_LOCATION = File.join(Dir.home, '.feeder/')
    CONFIG_FILE_NAME  = 'feeder_conf.yml'
    CONFIG_FILE = File.join(CONFIG_FILE_LOCATION, CONFIG_FILE_NAME)

    def initialize
      Settings.use :config_file, :commandline, :encrypted
      Settings.define 'gmail.login'
      Settings.define 'gmail.password', encrypted: true
      Settings.define 'setup_credentials', type: :boolean, default: false

      Settings[:encrypt_pass] = ENV['ENCRYPT_PASS']

      if Settings[:encrypt_pass].nil?
        puts "Missing config decryption password!\n\nUse: export ENCRYPT_PASS='your_password'"
        exit
      end

      Settings.resolve!

      if !(File.exists? CONFIG_FILE) || Settings[:setup_credentials]
        gmail_login, gmail_password = prompt_for_gmail_credentials
        create_config_file(gmail_login, gmail_password)
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

    def prompt_for_gmail_credentials
      print 'Gmail login: '
      login = gets.chomp
      begin
        print 'Gmail password (hidden): '
        password = STDIN.noecho(&:gets).chomp
        print "\nRetype Gmail password: "
        password_retype = STDIN.noecho(&:gets).chomp
        passwords_are_equal = password == password_retype
        puts "\nPasswords didn't match!\n\n" unless passwords_are_equal
      end until passwords_are_equal
      [login, password]
    end

    def gmail_credentials
      {
        login: Settings[:gmail][:login],
        password: Settings[:gmail][:password]
      }
    end

    private :read_settings!, :create_config_file, :prompt_for_gmail_credentials

  end
end