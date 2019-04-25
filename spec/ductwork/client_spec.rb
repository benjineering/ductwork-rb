RSpec.describe Client do
  let(:client) { Client.new(FIFO_PATH) }

  let(:server) { Server.new(FIFO_PATH) }

  before(:each) do
    File.delete(FIFO_PATH) if File.exist?(FIFO_PATH)
    server.create(LONG_TIMEOUT)
  end

  after(:each) do
    server.close if server.open?
    client.close if client.open?
  end

  it 'is a class' do
    expect(Client).to be_a Class
  end

  describe '.new' do
    # check string param is required

    it 'returns a client instance' do
      expect(client).to be_a Client
    end
  end

  describe '#path' do
    it 'returns the full path to the FIFO' do
      expect(client.path).to eq FIFO_PATH
    end
  end

  describe '#open' do
    context "when the pipe isn't opened for reading" do
      it 'raises a timeout error' do
        expect { 
          client.open(SHORT_TIMEOUT) 
        }.to raise_error Ductwork::TimeoutError
      end
    end

    context 'when the pipe is already open for reading' do
      it 'returns a pipe' do
        Thread.new { `echo p00ts >> #{FIFO_PATH}` }
        expect(client.open(LONG_TIMEOUT)).to be_a Pipe
      end
    end

    context 'when a block is passed' do
      skip 'yields an open pipe'

      skip 'closes the pipe when the block closes'
    end
  end

  describe '#open?' do
    context 'when client is open' do
      it 'returns true' do
        Thread.new { `echo p00ts >> #{FIFO_PATH}` }
        client.open(LONG_TIMEOUT)
        expect(client.open?).to be true
      end
    end

    context "when client isn't open" do
      it 'returns false' do
        expect(client.open?).to be false
      end
    end
  end
end
