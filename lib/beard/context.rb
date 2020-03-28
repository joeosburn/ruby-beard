# frozen_string_literal: true

class Beard::Context
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

  attr_reader :globals, :locals, :buffer, :blocks
  attr_writer :path

  def initialize(data, globals: {})
    @locals = [data]
    @globals = globals
    @buffer = ''
    @blocks = []

    globals.each do |global, val|
      exec.local_variable_set(global, val)
    end

    locals.each do |set|
      set.each do |local, val|
        exec.local_variable_set(local, val)
      end
    end

    # _capture_args = []
  end

  def eval(str)
    exec.eval(str)
  end

  def in_block(name)
    blocks.push(Block.new(name))
    yield
    block = blocks.pop
    exec.local_variable_set(block.name, block.buffer)
    globals[block.name] = block.buffer
    block.buffer
  end

  def capture(str)
    !blocks.empty? ? blocks.last.capture(str) : @buffer += str
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

  def exec
    @exec ||= binding
  end
end
