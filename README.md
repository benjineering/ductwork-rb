# Ductwork Ruby Gem

## Cross platform FIFO pipe action

```ruby
path = './tmp/dw.fifo'
timeout_ms = 2_000

server = Ductwork::Server.new(path)
client = Ductwork::Client.new(path)
server.create(timeout_ms)

write_pipe = nil
server_thread = Thread.new { write_pipe = server.open }
read_pipe = client.open(timeout_ms)
server_thread.join

write_pipe.write('p00ts')
puts read_pipe.read(100)
```
