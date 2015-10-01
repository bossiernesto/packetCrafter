module PacketWriter

  class BasicStruct
    include Abstract

    abstract_methods :encode, :decode

    protected

    def unpack_string(size)
      decode_table = [[1, 'C'], [2, 'n'], [4, 'N']]

      result = decode_table.select { |s, d| s == size }

      #Todo: put a nicer error
      raise PacketWriter::PacketWriterError, "No results found for size #{size}" unless result
      result.first.first
    end
  end

  class TypeValueStruct < BasicStruct


    attr_accessor :type, :length, :value, :lbytes, :tlinclude

    def initialize(type, length, lbytes = 1, tlinclude = false)
      self.type = type
      self.length = length
      self.lbytes = lbytes
      self.tlinclude = tlinclude
    end


    def encode
      s = "#{punpack_string(@ts)}#{punpack_string(@ls)}"
      [self.type, self.length, self.value].pack("#{s}a*")
    end

    def decode(raw)
      return null if self.type.nil? or self.length.nil?

      s = "#{self.unpack_string(self.type)}#{self.unpack_string self.length}}"
      type, length, tmp = raw.unpack("s#{s}a*")
      e_length = (length * lbytes) - (self.tlinclude ? (self.length + self.type) : 0)
      value, rest = tmp.unpack("a#{e_length}a*")
      return nil if value.empty? and length > 0
      [type, length, value, rest]
    end

    def set_decode(raw)
      self.type, self.length, self.lbytes = self.decode raw
    end

    def to_s
      encode
    end

    def to_str
      encode
    end

  end

  class TypeStruct < BasicStruct


  end

end