module ActiveFedora
  module Streamable
    module Datastreams
      unless ActiveFedora::Streamable::Datastreams.const_defined? :VERSION
        VERSION = '0.3.0'
      end
    end
  end
end
