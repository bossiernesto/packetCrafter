require 'bit-struct'
require_relative 'abstract'

module PacketWriter

  class BasicPacket < BitStruct
    include Abstract

    abstract_methods :fix, :check_packet
    attr_accessor :autofix

    def initialize(*args)
      self.autofix = true
      super *args
    end

    def to_s
      s = ''
      self.fields.filter {|f| f.name != 'payload'}.each do |field|
        s += "#{field.name} => #{self.send field.name}"
      end
      s
    end

  end

end