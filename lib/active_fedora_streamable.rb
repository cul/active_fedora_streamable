require 'active-fedora'
require 'active_support'
module ActiveFedora
  module Streamable
    module Datastreams
      extend ActiveSupport::Autoload
      autoload :Version
      # the output of this method should be assigned to the response_body of a controller
      # the bytes returned from the datastream dissemination will be written to the response
      # piecemeal rather than being loaded into memory as a String
      def stream(controller, parms=Hash.new)
        parms = {:dsid=>self.dsid, :pid=>self.pid, :finished=>false}.merge parms
        controller.headers['Last-Modified'] = self.lastModifiedDate || Time.now.ctime.to_s
        if self.dsSize
          controller.headers['Content-Length'] = self.dsSize.to_s
        else
          controller.headers['Transfer-Encoding'] = 'chunked'
        end
        #controller.response_body = ActiveFedora::Datastreams::Streamable::Streamer.new parms
        controller.response_body = Enumerator.new do |blk|
          repo = ActiveFedora::Base.connection_for_pid(parms[:pid])
          repo.datastream_dissemination(parms) do |res|
            res.read_body do |seg|
              puts "writing #{seg.length} bytes"
              blk << seg
            end
          end
        end
      end
    end
  end
end