module PacketWriter
  class PcapService
    begin
      require 'pcaprub'
    rescue LoadError => e
      puts 'You need to have pcapruby installed'
      raise RuntimeError, 'You need to install the pcaprub gem'
    end

    attr_accessor :interface, :capture, :mtu, :timeout

    DEFAULT_MTU = 1500
    DEFAULT_TIMEOUT = 200

    #MTU try to check if the mtu should be 1500 -> default or superior
    def initialize(interface = nil, mtu = DEFAULT_MTU, timeout = DEFAULT_TIMEOUT)
      self.interface = interface
      self.mtu = mtu
      self.timeout = timeout
    end

    def open_interface
      raise PacketWriterError, 'You need to specify the interface before sending layer 2 packets' if self.interface.nil?
      begin
        self.capture = Pcap::open_live self.interface, self.mtu, false, self.timeout
      rescue PCAPRUBError => e
        puts "Pcap: can't open device '#{self.interface}' (#{e})"
        return
      end
    end

    def send_packet(payload)
      #send a packet through the TCP/IP layer 2
      self.open_interface if self.capture.nil?
      begin
        result = self.capture.inject(payload)
        self.close
        result
      rescue Exception => e
        puts "Pcap: error while sending packet on '#{self.interface}' (#{e})"
      end
    end

    def close
      self.capture.pcap_close
      self.capture = nil
    end

  end

end