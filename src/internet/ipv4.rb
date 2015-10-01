require_relative '../basicPacket'

module PacketWriter
  module Internet

    class IPv4 < PacketWriter::BasicPacket
      include PacketWriter::InternetGoodies

      attr_accessor :options

      unsigned :version, 4, {:default => 4} # Version (defaults to 4)
      unsigned :hlen, 4, {:default => 5} # Header length in multiples of 4 octets (defaults to 5)
      unsigned :tos, 8 # TOS
      unsigned :len, 16 # Datagram length
      unsigned :id, 16 #id
      unsigned :flags, 3 #Flags
      unsigned :frag_offset, 13 #Fragmentation offset
      unsigned :ttl, 8 # Time to live
      unsigned :protocol, 8 #Protocol
      unsigned :checksum, 16 #Checksum
      octets :src_ip, 32 # Source IP address, passed as four octets separated by periods
      octets :dst_ip, 32 # Destination IP address, passed as four octets separated by periods
      rest :payload # Payload

      def initialize(*args)
        self.options = []
        super
      end

      #Options
      # The options field is not often used. Note that the value in the IHL field must include enough extra 32-bit words to hold all the options (plus any padding needed to ensure that the header contains an integer size of 32-bit words).
      # The list of options may be terminated with an EOL (End of Options List, 0x00) option; this is only necessary if the end of the options would not otherwise coincide with the end of the header.
      # The possible options that can be put in the header are as follows:
      #
      # Field           Size(bits)  Description
      # Copied          1           Set to 1 if the options need to be copied into all fragments of a fragmented packet.
      # Option Class    2           A general options category. 0 is for "control" options, and 2 is for "debugging and measurement". 1, and 3 are reserved.
      # Option Number   5           Specifies an option.
      # Option Length   8           Indicates the size of the entire option (including this field). This field may not exist for simple options.
      # Option Data     Variable    Option-specific data. This field may not exist for simple options.
      def add_option(size, value)
        struct = PacketWriter.TypeValueStruct.new 1, 1
        struct.type = size
        struct.value = value
        struct.length = value.length + 2
        self.options << struct.encode
      end

      # Check the checksum for this IP datagram
      def checksum?
        self.checksum == self.compute_checksum
      end

      def recompute_checksum
        self.checksum = compute_checksum
      end

      # Perform all the niceties necessary prior to sending
      # this IP datagram out.  Append the options, update len and hlen,
      # and fix the checksum.
      def fix
        new_payload = self.options.join

        # pad to a multiple of 32 bits
        new_payload = self.pad_payload new_payload

        #prepend the options before the next layer payload
        self.payload = new_payload + self.payload
        self.hlen += new_payload.length/4
        self.len = self.payload.length + self.class.bit_length/8
        self.recompute_checksum
      end

      def pad_payload(payload)
        if payload.length %4 != 0

          while payload.length % 4 != 3
            payload = "\x01#{payload}"
          end

          # make sure the last byte is an EOL
          raise PacketWriter::PacketWriterError, '' unless payload.length % 4 == 3
          payload += "\x00"
        end
        payload
      end

      def check_packet
        #TODO
      end

      private

      def compute_checksum
        pseudo = []
        pseudo << ((((self.version << 4) | self.hlen) << 8) | self.tos)
        pseudo << self.len
        pseudo << self.id
        pseudo << ((self.flags << 13) | self.frag_offset)
        pseudo << ((self.ttl << 8) | self.protocol)
        pseudo << 0
        pseudo << self.ipv4_to_long(self.src_ip)
        pseudo << self.ipv4_to_long(self.dst_ip)
        self.process_checksum(pseudo.pack('nnnnnnNN'))
      end
    end
  end

end