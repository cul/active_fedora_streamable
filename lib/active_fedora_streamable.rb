require 'active-fedora'
module ActiveFedora
  module Datastreams
    module Streamable
      # the output of this method should be assigned to the response_body of a controller
      # the bytes returned from the datastream dissemination will be written to the response
      # piecemeal rather than being loaded into memory as a String
      def stream(parms=Hash.new)
        parms = {:dsid=>self.dsid, :pid=>self.pid}.merge parms
        return ActiveFedora::Datastreams::Streamable::Streamer.new parms
      end
      
      class Streamer
        def initialize(parms=Hash.new)
          raise "ActiveFedora::Datastreams::Streamable::Streamer requires opts[:dsid]" unless parms[:dsid]
          raise "ActiveFedora::Datastreams::Streamable::Streamer requires opts[:pid]" unless parms[:pid]
          @rubydora_parms = parms
          # Rails 3.0.x calls the iterator twice. This flag should have no effect in 3.1.x
          @done = false
        end

        # Rails 3 expects to iterate over the streamed segments
        # RestClient's block needs to close over the Rails block,
        # so we create it here in the iterator
        def each(&output_block)
          return if @done
          block_response =  Proc.new { |res|
            res.read_body do |seg|
              output_block.call(seg)
            end
          }
          repo = ActiveFedora::Base.connection_for_pid(@rubydora_parms[:pid])
          repo.datastream_dissemination @rubydora_parms.dup, &block_response
          @done = true
        end
      end
    end
  end
end
require 'active_fedora_streamable/version'