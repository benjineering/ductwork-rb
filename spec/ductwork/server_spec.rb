RSpec.describe Server do
  let(:server) { Server.new(FIFO_PATH) }

  let(:client) { Ductwork::Client.new(FIFO_PATH) }

  before(:each) { File.delete(FIFO_PATH) if File.exist?(FIFO_PATH) }

  after(:each) do
    server.close if server.open?
    client.close if client.open?
  end

  it 'is a class' do
    expect(Server).to be_a Class
  end

  describe '.new' do
    # TODO: check string param is required

    it 'returns a Server' do
      expect(server).to be_a Server
    end
  end

  describe '#path' do
    it 'returns the full path to the FIFO' do
      expect(server.path).to eq FIFO_PATH
    end
  end

  describe '#create' do
    it 'creates a FIFO pipe' do
      server.create(LONG_TIMEOUT)
      expect(File.exist?(FIFO_PATH)).to be true
    end
  end

  describe '#open' do
    before(:each) { server.create(LONG_TIMEOUT) }

    context "when the pipe isn't opened for reading" do
      it 'raises a timeout error' do
        expect { 
          server.open(SHORT_TIMEOUT) 
        }.to raise_error Ductwork::TimeoutError
      end
    end

    context 'when the pipe is already open for reading' do
      it 'returns an open pipe' do
        Thread.new { `cat #{FIFO_PATH}` }
        pipe = server.open
        expect(pipe).to be_a Pipe
        expect { pipe.write('p00ts') }.not_to raise_error
      end

      context 'when a block is passed' do
        skip 'yields an open pipe'

        skip 'closes the pipe when the block closes'
      end
    end
  end

  skip '#close'

  skip '#write'
end
