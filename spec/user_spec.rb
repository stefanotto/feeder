require 'feeder/user'

describe 'User' do

=begin
  let(:valid_user) {
    @valid_user = Feeder::User.new username: "Andy", email_address:
  }

  subject {:valid_user}
=end

  describe '.new' do
    context 'when init options are missing'  do

      let(:option_keys) {Feeder::User::MANDATORY_INIT_OPTIONS}

      it 'should raise an exception' do
        option_hash = Hash[*option_keys.zip(option_keys).flatten]
        option_keys.each do |key_to_remove|
          options = option_hash.reject {|key,| key == key_to_remove}
          expect {Feeder::User.new(options)}.to raise_error(ArgumentError)
        end
      end

    end
  end

end


