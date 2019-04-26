RSpec.describe Client do
  let(:client) { Client.new(FIFO_PATH) }

  let(:server) { Server.new(FIFO_PATH) }

  before(:each) do
    File.delete(FIFO_PATH) if File.exist?(FIFO_PATH)
    server.create(LONG_TIMEOUT)
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
    context "when the pipe isn't opened for writing" do
      it 'raises a timeout error' do
        expect { client.open(SHORT_TIMEOUT) }.to raise_error TimeoutError
        expect(client.open?).to be false
      end
    end

    context 'when the pipe is opened for writing' do
      it 'returns a pipe' do
        pipe = nil
        thread = Thread.new { pipe = client.open(LONG_TIMEOUT) }
        `echo p00t >> #{FIFO_PATH}`
        thread.join
        expect(pipe).to be_a Pipe
        client.close
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
        thread = Thread.new { client.open(LONG_TIMEOUT) }
        `echo p00t >> #{FIFO_PATH}`
        thread.join
        expect(client.open?).to be true
        client.close
      end
    end

    context "when client isn't open" do
      it 'returns false' do
        expect(client.open?).to be false
      end
    end
  end

  skip '#close'

  skip '#read'
end
