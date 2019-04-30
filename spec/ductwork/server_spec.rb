RSpec.describe Server do
  let(:server) { Server.new(FIFO_PATH) }

  before(:each) { File.delete(FIFO_PATH) if File.exist?(FIFO_PATH) }

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
        expect { server.open(SHORT_TIMEOUT) }.to raise_error TimeoutError
        expect(server.open?).to be false
      end
    end

    context 'when the pipe is opened for reading first' do
      it 'returns an open pipe' do
        pipe = nil
        Thread.new { `cat #{FIFO_PATH}` }
        thread = Thread.new { pipe = server.open }
        thread.join
        expect(pipe).to be_a Pipe
        server.close
      end

      context 'when the pipe is opened for writing first' do
        it 'returns an open pipe', :focus do
          pipe = nil
          thread = Thread.new { pipe = server.open }
          Thread.new { `cat #{FIFO_PATH}` }          
          thread.join
          expect(pipe).to be_a Pipe
          server.close
        end
      end

      context 'when a block is passed' do
        skip 'yields an open pipe'

        skip 'closes the pipe when the block closes'
      end
    end
  end

  skip '#open?'

  skip '#close'

  skip '#write'
end
