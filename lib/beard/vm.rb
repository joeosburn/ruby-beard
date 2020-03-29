# frozen_string_literal: true

class Beard::VM
  class Block
    attr_reader :name, :buffer

    def initialize(name)
      @name = name
      @buffer = ''
    end

    def capture(str)
      @buffer += str
    end
  end

  Context = Struct.new(:vars, :buffer, :exec) do
    def initialize(*)
      super
      self.buffer ||= ''
      self.exec ||= binding
    end
  end

  attr_reader :heap, :contexts, :blocks, :cache
  attr_accessor :path

  def initialize(data, cache, heap: {})
    @cache = cache
    @contexts = [Context.new(data)]
    @heap = heap
    @blocks = []
  end

  def eval(str)
    exec.eval(str)
  end

  def buffer
    contexts.last.buffer
  end

  def buffer=(val)
    contexts.last.buffer = val
  end

  def in_block(name)
    blocks.push(Block.new(name))

    yield

    blocks.pop.tap do |block|
      exec.local_variable_set(block.name, block.buffer)
      heap[block.name] = block.buffer
    end.buffer
  end

  def capture(str)
    !blocks.empty? ? blocks.last.capture(str) : self.buffer += str
  end

  def include(include_path, data = {})
    contexts.push(Context.new(data))
    prepare_exec
    cache.retrieve(include_path, path).call(self).tap { contexts.pop }
  end

  def encode(str)
    capture(str.
      gsub(/&(?!\\w+;)/, '&#38;').
      gsub(/\</, '&#60;').
      gsub(/\>/, '&#62;').
      gsub(/\"/, '&#34;').
      gsub(/\'/, '&#39;').
      gsub(%r{/}, '&#47;'))
  end

  private

  def prepare_exec
    heap.merge(contexts.map(&:vars).reduce(&:merge)).each do |name, val|
      exec.local_variable_set(name, val)
    end
  end

  def exec
    contexts.last.exec
  end
end
