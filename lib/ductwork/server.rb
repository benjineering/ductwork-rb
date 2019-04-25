require 'ductwork/ductwork'

module Ductwork
  class Server
    def open(timeout = nil)
      pipe = nil

      thread = Thread.new do
        pipe = timeout.nil? ? open_async : open_async(timeout)
      end
      
      thread.join
      pipe
    end
  end
end
