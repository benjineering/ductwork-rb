RSpec.describe Pipe do
  let(:path) { File.expand_path('./tmp/dw.fifo') }

  let(:server) { Server.new(path) }

  let(:client) { Client.new(path) }

  let(:timeout) { 2000 }

  before(:each) do
    File.delete(path) if File.exist?(path)
    server.create(timeout)
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
      pipe = nil
      Thread.new { `cat #{path}` }
      server_thread = Thread.new { pipe = server.open }
      server_thread.join      
      expect { pipe.write('p00ts') }.not_to raise_error
    end
  end

  skip '#read'

  skip '#readable?'

  skip '#writable?'
end
