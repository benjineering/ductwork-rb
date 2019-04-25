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

  describe '#write' do
    it 'is ok' do
      Thread.new { `cat #{FIFO_PATH}` }
      pipe = server.open
      expect { pipe.write('p00ts') }.not_to raise_error
    end
  end

  skip '#read'

  skip '#readable?'

  skip '#writable?'
end
