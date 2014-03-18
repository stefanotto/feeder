require 'yaml'

module Feeder
  class User

    USER_DUMP_FILE = 'users.yml'
    MANDATORY_INIT_OPTIONS = [:username, :email_address]

    @@users = Hash.new

    attr_reader :email_addresses

    def initialize(options)
      MANDATORY_INIT_OPTIONS.each do |key|
        unless options.has_key? key
          error_message = "Can't create user. '#{key}'-parameter is mandatory!"
          raise ArgumentError, error_message
        end
      end
      @username = options.fetch(:username)
      @email_addresses = []
      add_email_address! options.fetch(:email_address)
      @feed_patterns = []
      add_feed_pattern! options.fetch(:feed_pattern, /(f|F)eed/)
      @@users[@username.to_sym] = self
      User.persist!
      raise
    end

    def add_email_address!(email_address)
      @email_addresses << email_address
    end

    def add_feed_pattern!(feed_pattern)
      @feed_patterns << feed_pattern
    end

    def may_feed?(email_subject)
      @feed_patterns.any? {|pattern| email_subject =~ pattern }
    end

    def self.find_by_email(email_address)
      found_user = @@users.find {|key, user|
        user.email_addresses.any? do |user_email|
          user_email.downcase == email_address.downcase
        end
      }
      return nil unless found_user
      found_user[1]
    end

    def self.persist!
      user_dump = YAML::dump @@users
      File.open(USER_DUMP_FILE, 'w') do |file|
        file.puts user_dump
      end
    end

    def self.import!
      @@users = YAML::load(File.read(USER_DUMP_FILE))
    end

  end
end

#Feeder::User.new(username: 'user', email_addresss: 'foo@mail.com')
