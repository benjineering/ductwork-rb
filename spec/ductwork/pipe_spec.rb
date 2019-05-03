RSpec.describe Pipe do
  let(:server) { Server.new(FIFO_PATH) }
  let(:client) { Client.new(FIFO_PATH) }

  before(:each) do
    File.delete(FIFO_PATH) if File.exist?(FIFO_PATH)
    server.create(LONG_TIMEOUT)
  end

  after(:each) do
    server.close if server.open?
    client.close if client.open?
  end

  describe '.new' do
    skip 'when no parent is passed'

    context 'when a server is passed' do
      it 'returns a Pipe' do
        expect(Pipe.new(server)).to be_a Pipe
      end
    end

    context 'when a client is passed' do
      it 'returns a Pipe' do
        expect(Pipe.new(client)).to be_a Pipe
      end
    end
  end

  describe '#read' do
    skip 'when created from Server#open'

    context 'when created from Client#open' do
      it 'is ok' do
        pipe = nil
        thread = Thread.new { pipe = client.open(LONG_TIMEOUT) }
        `echo p00t >> #{FIFO_PATH}`
        thread.join
        expect { pipe.read(100) }.not_to raise_error
        client.close
      end
    end
  end

  describe '#write' do
    skip 'when created from Server#open' do
      it 'is ok' do
        pipe = nil
        Thread.new { `cat #{FIFO_PATH}` }
        Thread.new { pipe = server.open }.join
        expect { pipe.write('p00ts') }.not_to raise_error
      end
    end

    context 'when created from Client#open'
  end

  skip '#readable?'

  skip '#writable?'
end
