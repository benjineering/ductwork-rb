Server = Ductwork::Server

RSpec.describe Server do
  let(:path) { '/Users/ben/Desktop/dw.fifo' }

  let(:server) { Server.new(path) }

  let(:timeout) { 500 }

  before(:each) { File.delete(path) if File.exist?(path) }

  it 'is a class' do
    expect(Server).to be_a Class
  end

  describe '.new' do
    # check string param is required

    it 'returns a Server' do
      expect(server).to be_a Server
    end
  end

  describe '#create' do
    it 'creates a FIFO pipe' do
      server.create(timeout)
      expect(File.exist?(path)).to be true
    end
  end

  describe '#open' do
    # TODO: timeout context

    it 'returns an IO' do
      thread = Thread.new { IO.read(path) }
      expect(server.open).to be_a IO
      thread.join
    end
  end
end
