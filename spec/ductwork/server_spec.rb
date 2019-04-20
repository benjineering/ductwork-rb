Server = Ductwork::Server

RSpec.describe Server do
  let(:path) { File.expand_path('./tmp/dw.fifo') }

  let(:server) { Server.new(path) }

  let(:client) { Ductwork::Client.new(path) }

  let(:timeout) { 1000 }

  before(:each) { File.delete(path) if File.exist?(path) }

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
      expect(server.path).to eq path
    end
  end

  describe '#create' do
    it 'creates a FIFO pipe' do
      server.create(timeout)
      expect(File.exist?(path)).to be true
    end
  end

  describe '#open' do
    before(:each) { server.create(timeout) }

    context "when the pipe isn't opened for reading" do
      it 'raises a timeout error after the timeout is reached' do
        start = Time.now
        expect { server.open }.to raise_error Ductwork::TimeoutError
        finish = Time.now
        actual_timeout = (finish - start) * 1000
        #expect(actual_timeout).to eq timeout # TODO: custom matcher raise_error_after_ms
      end

      context 'when a timeout value is passed' do
        skip 'raises a timeout error after the overidden timeout is reached'
      end
    end

    context 'when the pipe is already open for reading' do
      it 'returns an open IO' do
        result = nil
        Thread.new { `cat #{path}` }
        server_thread = Thread.new { result = server.open }
        server_thread.join
        expect(result).to be_a IO
      end
    end
  end
end
