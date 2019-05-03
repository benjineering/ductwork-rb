RSpec.describe Pipe do
  let(:server) { Server.new(FIFO_PATH) }

  let(:client) { Client.new(FIFO_PATH) }

  before(:each) do
    File.delete(FIFO_PATH) if File.exist?(FIFO_PATH)
    server.create(LONG_TIMEOUT)
  end

  it 'is a class' do
    expect(Pipe).to be_a Class
  end

  describe '.new' do
    # TODO: check base param is required

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
    it 'is ok' do
      pipe = nil
      thread = Thread.new { pipe = client.open(LONG_TIMEOUT) }
      `echo p00t >> #{FIFO_PATH}`
      thread.join
      expect { pipe.read(100) }.not_to raise_error
      client.close
    end
  end

  describe '#write' do
    it 'is ok' do
      pipe = nil
      Thread.new { `cat #{FIFO_PATH}` }
      thread = Thread.new { pipe = server.open }
      thread.join
      expect { pipe.write('p00ts') }.not_to raise_error
      server.close
    end
  end

  skip '#readable?'

  skip '#writable?'
end
