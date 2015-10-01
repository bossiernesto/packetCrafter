require_relative '../basicPacket'


module PacketWriter

  module Network
    class Ethernet < PacketWriter::BasicPacket
      include PacketWriter::EthernetGoodies

      #Types
      ETHER_IPV4 =0x0800 #Internet Protocol version 4 (IPv4)
      ETHER_ARP =0x0806 #Address Resolution Protocol (ARP)
      ETHER_WAKELAN =0x0842 #Wake-on-LAN
      ETHER_VIDEOTRANSPORT = 0x22F0 #Audio Video Transport Protocol as defined in IEEE Std 1722-2011
      ETHER_TRILL = 0x22F3 #IETF TRILL Protocol
      ETHER_DECNET = 0x6003 #DECnet Phase IV
      ETHER_RARP = 0x8035 #Reverse Address Resolution Protocol
      ETHER_APPLETALK = 0x809B #AppleTalk (Ethertalk)
      ETHER_AARP = 0x80F3 #AppleTalk Address Resolution Protocol (AARP)
      ETHER_IEEE = 0x8100 #VLAN-tagged frame (IEEE 802.1Q) & Shortest Path Bridging IEEE 802.1aq
      ETHER_IPX = 0x8137 #IPX
      ETHER_IPX = 0x8138 #IPX
      ETHER_QNX = 0x8204 #QNX Qnet
      ETHER_IPV6 = 0x86DD #Internet Protocol Version 6 (IPv6)
      ETHER_FLOWCONTROL = 0x8808 #Ethernet flow control
      ETHER_8023 = 0x8809 #Slow Protocols (IEEE 802.3)
      ETHER_COBRA = 0x8819 #CobraNet
      ETHER_MPLSUNI = 0x8847 #MPLS unicast
      ETHER_MPLSMULTI = 0x8848 #MPLS multicast
      ETHER_PPOEDISCO = 0x8863 #PPPoE Discovery Stage
      ETHER_PPOESESSION = 0x8864 #PPPoE Session Stage
      ETHER_JUMBO = 0x8870 #Jumbo Frames
      ETHER_HOMEPLUG =  0x887B #HomePlug 1.0 MME
      ETHER_EAP = 0x888E #EAP over LAN (IEEE 802.1X)
      ETHER_PROFINET = 0x8892 #PROFINET Protocol
      ETHER_HYPERSCSI = 0x889A #HyperSCSI (SCSI over Ethernet)
      ETHER_ATA = 0x88A2 #ATA over Ethernet
      ETHER_ETHERCAT = 0x88A4 #EtherCAT Protocol
      ETHER_BRIDGING= 0x88A8 #Provider Bridging (IEEE 802.1ad) & Shortest Path Bridging IEEE 802.1aq
      ETHER_POWERLINK = 0x88AB #Ethernet Powerlink[citation needed]
      ETHER_LLDP = 0x88CC #Link Layer Discovery Protocol (LLDP)
      ETHER_SERCOS = 0x88CD #SERCOS III
      ETHER_HOMPLUGAV = 0x88E1 #HomePlug AV MME[citation needed]
      ETHER_MRP = 0x88E3 #Media Redundancy Protocol (IEC62439-2)
      ETHER_SEC = 0x88E5 #MAC security (IEEE 802.1AE)
      ETHER_PBB = 0x88E7 #Provider Backbone Bridges (PBB) (IEEE 802.1ah)
      ETHER_PTP = 0x88F7 #Precision Time Protocol (PTP) over Ethernet (IEEE 1588)
      ETHER_CFM = 0x8902 #IEEE 802.1ag Connectivity Fault Management (CFM) Protocol / ITU-T Recommendation Y.1731 (OAM)
      ETHER_FCOE = 0x8906 #Fibre Channel over Ethernet (FCoE)
      ETHER_FCOEINIT = 0x8914 #FCoE Initialization Protocol
      ETHER_ROCE = 0x8915 #RDMA over Converged Ethernet (RoCE)
      ETHER_HSR = 0x892F #High-availability Seamless Redundancy (HSR)
      ETHER_CTP = 0x9000 #Ethernet Configuration Testing Protocol
      ETHER_VLLT = 0xCAFE #Veritas Low Latency Transport (LLT) for Veritas Cluster Server

      hex_octets :dst_mac, 48 # Destination MAC address
      hex_octets :src_mac, 48 # Source MAC address
      unsigned :type, 16, { :default => ETHER_IPV4 }   # Protocol of payload send with this ethernet datagram.  Defaults to IPV4
      rest :payload # Payload

      def check_packet
        self.class._constants.filter {|c| c.to_s.starts_with? 'ETHER_'}.include? self.type
      end

      def fix
      end

    end
  end

end