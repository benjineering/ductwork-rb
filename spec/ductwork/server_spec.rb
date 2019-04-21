RSpec.describe Server do
  let(:path) { File.expand_path('./tmp/dw.fifo') }

  let(:server) { Server.new(path) }

  let(:client) { Ductwork::Client.new(path) }

  let(:short_timeout) { 50 }

  let(:timeout) { 2000 }

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
      it 'raises a timeout error' do
        expect { server.open(short_timeout) }.to raise_error Ductwork::TimeoutError
      end
    end

    context 'when the pipe is already open for reading' do
      it 'returns an open pipe' do
        pipe = nil
        Thread.new { `cat #{path}` }
        server_thread = Thread.new { pipe = server.open }
        server_thread.join
        expect(pipe).to be_a Pipe
        expect { pipe.write('p00ts') }.not_to raise_error
      end
    end
  end
end
