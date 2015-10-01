module PacketWriter

  class Packet

    require 'socket'
    require_relative '../src/pcap/pcap'

    attr_accessor :is_bsd, :interface, :layers

    def initialize(interface= nil)
      self.is_bsd= !Socket.const_defined? 'SOL_IP'
      self.pcap = PacketWriter::PcapService.new interface

      (2..4).each do |lvl|
        self.send :define_method, "layer#{lvl}".to_sym do
          self.layers[lvl]
        end

        self.send :define_method, "layer#{lvl}=".to_sym do |payload|
          self.layers[lvl] = payload
        end

        self.send :alias_method, "l#{lvl}".to_sym, "layer#{lvl}".to_sym
        self.send :alias_method, "l#{lvl}=".to_sym, "layer#{lvl}=".to_sym
      end
    end

    #We don't have to fuck up the send method, so we have an uglier send_packet method name
    def send_packet
      return self.send_l2_packet unless self.l2.nil?
      self.send_l3_packet
    end

    def to_s
      s = ''
      self.layers.compact.each do |l|
        s << "#{l.class}: "
        s << l.to_s
        s << "\n"
      end
      s
    end

    private

    def send_l2_packet
      payload = self.pack_packet

      begin
        self.pcap.open_interface
        self.pcap.send_packet payload
      rescue Exception => e
        puts "Error sending the payload: #{payload} through pcap."
        puts e.message
        raise PackeWriter.new e
      end
    end

    def send_l3_packet
      begin
        socket = Socket.open Socket::PF_INET, Socket::SOCK_RAW, Socket::IPPROTO_RAW
        self.set_l3_socket socket
      rescue Errno::EPERM
        raise PacketWriter::PacketWriterError, 'You need to run the program as root'
      end

      socket.send self.pack_packet, 0, Socket.pack_sockaddr_in(1024, self.l3[3].dst_ip)
    end

    def set_l3_socket(socket)
      unless self.is_bsd
        socket.setsockopt Socket::SOL_IP, Socket::IP_HDRINCL, true
        return socket
      end
      socket.setsockopt Socket::IPPROTO_IP, Socket::IP_HDRINCL, true
    end

    def pack_packet
      last_payload = ''
      orig_payload = ''

      self.layers.compact.reverse.each do |layer|

        layer.check_packet

        # save the original payload
        orig_payload = layer.payload

        layer.payload += last_payload
        layer.fix if (layer.autofix)

        # payload was not modified by fix, so reset it to what it used to be
        # or
        # payload was modified by fix.  chop off what we added /this assumes that what we added is still at the end)
        layer.payload = (layer.payload == orig_payload + last_payload) ? orig_payload : layer.payload.slice(0, layer.payload.length - last_payload.length)

        # save this layer for the next layer
        last_payload += layer
      end

      self.concat_layers
    end

    def concat_layers
      self.layers.compact.join ''
    end


  end

end
