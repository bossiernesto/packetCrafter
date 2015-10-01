module PacketWriter
  class PacketWriterError < StandardError
    def initialize(e = nil)
      super e
      if e.is_a? Exception
        set_backtrace e.backtrace
        message.prepend "#{e.class}:"
      end
    end
  end
end