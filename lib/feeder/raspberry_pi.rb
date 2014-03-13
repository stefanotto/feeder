require 'pi_piper'

module Feeder
  class RaspberryPi
    
    def initialize
      @pin_numbers = [4, 17, 18, 22]
      @half_stepping_sequence = 
      [ [1,0,0,0],
        [1,1,0,0],
        [0,1,0,0],
        [0,1,1,0],
        [0,0,1,0],
        [0,0,1,1],
        [0,0,0,1],
        [1,0,0,1]
      ]

      @pins = {}
      @pin_numbers.each do |pin_number|
        @pins[pin_number] = PiPiper::Pin.new(pin: pin_number, direction: :out)
      end
    end

    def rotate_motor()
      logger.debug 'rotating...'
      # should run 512 times for a full rotation
      # but the motor seems to have mechanical inaccuracies
      510.times do 
        @half_stepping_sequence.each do |pin_config|
          0.upto(3) do |i|
            if pin_config[i] == 1
              @pins[@pin_numbers[i]].on
            elsif pin_config[i] == 0
              @pins[@pin_numbers[i]].off
            end
            sleep(0.0015)
          end
        end
      end
      logger.debug '...finished'
    end

  end

end