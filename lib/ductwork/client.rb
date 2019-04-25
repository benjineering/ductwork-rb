require 'ductwork/ductwork'

module Ductwork
  class Client < Base
    def open(timeout)
      pipe = nil
      Thread.new { pipe = open_async(timeout) }.join
      pipe
    end
  end
end
