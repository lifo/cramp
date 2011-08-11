# encoding: BINARY

# The MIT License - Copyright (c) 2009 Ilya Grigorik
# Thank you https://github.com/igrigorik/em-websocket
#
# Copyright (c) 2009 Ilya Grigorik
# 
# Permission is hereby granted, free of charge, to any person obtaining
# a copy of this software and associated documentation files (the
# "Software"), to deal in the Software without restriction, including
# without limitation the rights to use, copy, modify, merge, publish,
# distribute, sublicense, and/or sell copies of the Software, and to
# permit persons to whom the Software is furnished to do so, subject to
# the following conditions:
# 
# The above copyright notice and this permission notice shall be
# included in all copies or substantial portions of the Software.
# 
# THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND,
# EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF
# MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND
# NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT HOLDERS BE
# LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER IN AN ACTION
# OF CONTRACT, TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN CONNECTION
# WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE.

module Cramp
  class Protocol10FrameParser
    class WebSocketError < RuntimeError; end

    class MaskedString < String
      # Read a 4 bit XOR mask - further requested bytes will be unmasked
      def read_mask
        if respond_to?(:encoding) && encoding.name != "ASCII-8BIT"
          raise "MaskedString only operates on BINARY strings"
        end
        raise "Too short" if bytesize < 4 # TODO - change
        @masking_key = String.new(self[0..3])
      end

      # Removes the mask, behaves like a normal string again
      def unset_mask
        @masking_key = nil
      end

      def slice_mask
        slice!(0, 4)
      end

      def getbyte(index)
        if @masking_key
          masked_char = super
          masked_char ? masked_char ^ @masking_key.getbyte(index % 4) : nil
        else
          super
        end
      end

      def getbytes(start_index, count)
        data = ''
        count.times do |i|
          data << getbyte(start_index + i)
        end
        data
      end
    end

    attr_accessor :data

    def initialize
      @data = MaskedString.new
      @application_data_buffer = '' # Used for MORE frames
    end
    
    def process_data
      messages = []
      error = false

      while !error && @data.size >= 2
        pointer = 0

        fin = (@data.getbyte(pointer) & 0b10000000) == 0b10000000
        # Ignoring rsv1-3 for now
        opcode = @data.getbyte(pointer) & 0b00001111
        pointer += 1

        mask = (@data.getbyte(pointer) & 0b10000000) == 0b10000000
        length = @data.getbyte(pointer) & 0b01111111
        pointer += 1

        raise WebSocketError, 'Data from client must be masked' unless mask

        payload_length = case length
        when 127 # Length defined by 8 bytes
          # Check buffer size
          if @data.getbyte(pointer+8-1) == nil
            debug [:buffer_incomplete, @data]
            error = true
            next
          end
          
          # Only using the last 4 bytes for now, till I work out how to
          # unpack 8 bytes. I'm sure 4GB frames will do for now :)
          l = @data.getbytes(pointer+4, 4).unpack('N').first
          pointer += 8
          l
        when 126 # Length defined by 2 bytes
          # Check buffer size
          if @data.getbyte(pointer+2-1) == nil
            debug [:buffer_incomplete, @data]
            error = true
            next
          end
          
          l = @data.getbytes(pointer, 2).unpack('n').first
          pointer += 2
          l
        else
          length
        end

        # Compute the expected frame length
        frame_length = pointer + payload_length
        frame_length += 4 if mask

        # Check buffer size
        if @data.getbyte(frame_length - 1) == nil
          debug [:buffer_incomplete, @data]
          error = true
          next
        end

        # Remove frame header
        @data.slice!(0...pointer)
        pointer = 0

        # Read application data (unmasked if required)
        @data.read_mask if mask
        pointer += 4 if mask
        application_data = @data.getbytes(pointer, payload_length)
        pointer += payload_length
        @data.unset_mask if mask
        
        # Throw away data up to pointer
        @data.slice!(0...pointer)

        frame_type = opcode_to_type(opcode)

        if frame_type == :continuation && !@frame_type
          raise WebSocketError, 'Continuation frame not expected'
        end

        if !fin
          debug [:moreframe, frame_type, application_data]
          @application_data_buffer << application_data
          @frame_type = frame_type
        else
          # Message is complete
          if frame_type == :continuation
            @application_data_buffer << application_data
            messages << [@frame_type, @application_data_buffer]
            @application_data_buffer = ''
            @frame_type = nil
          else
            messages << [frame_type, application_data]
          end
        end
      end # end while

      messages
    end
    
    def send_frame(frame_type, application_data)
      debug [:sending_frame, frame_type, application_data]

      # Protocol10FrameParser doesn't have any knowledge of :closing in Cramp
      # if @state == :closing && data_frame?(frame_type)
      #   raise WebSocketError, "Cannot send data frame since connection is closing"
      # end

      frame = ''

      opcode = type_to_opcode(frame_type)
      byte1 = opcode | 0b10000000 # fin bit set, rsv1-3 are 0
      frame << byte1

      length = application_data.size
      if length <= 125
        byte2 = length # since rsv4 is 0
        frame << byte2
      elsif length < 65536 # write 2 byte length
        frame << 126
        frame << [length].pack('n')
      else # write 8 byte length
        frame << 127
        frame << [length >> 32, length & 0xFFFFFFFF].pack("NN")
      end

      frame << application_data
    end

    def send_text_frame(data)
      send_frame(:text, data)
    end

    private

    FRAME_TYPES = {
      :continuation => 0,
      :text => 1,
      :binary => 2,
      :close => 8,
      :ping => 9,
      :pong => 10,
    }
    FRAME_TYPES_INVERSE = FRAME_TYPES.invert
    # Frames are either data frames or control frames
    DATA_FRAMES = [:text, :binary, :continuation]

    def type_to_opcode(frame_type)
      FRAME_TYPES[frame_type] || raise("Unknown frame type")
    end

    def opcode_to_type(opcode)
      FRAME_TYPES_INVERSE[opcode] || raise(DataError, "Unknown opcode")
    end

    def data_frame?(type)
      DATA_FRAMES.include?(type)
    end

    def debug(*data)
      if @debug
        require 'pp'
        pp data
        puts
      end
    end

  end
end
