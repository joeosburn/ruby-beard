# frozen_string_literal: true

class Beard::VM
  class Block
    attr_reader :name, :buffer

    def initialize(name)
      @name = name
      @buffer = ''
    end

    def capture(str)
      @buffer += str.to_s
    end
  end

  Context = Struct.new(:vars, :buffer, :exec, :extends_path) do
    def initialize(*)
      super
      self.buffer ||= ''
      self.exec ||= binding
    end
  end

  BLOCK_INSTRUCTIONS = %I[block for].freeze
  END_INSTRUCTIONS = %I[end block_end].freeze

  attr_reader :heap, :contexts, :blocks, :cache
  attr_accessor :template_path

  def initialize(data, cache, heap: {})
    @cache = cache
    @contexts = [Context.new(data)]
    @heap = heap
    @blocks = []
    prepare_exec
  end

  def execute(instructions, position = 0, map = Map.new(self))
    instruction = instructions[position]
    result = nil

    while instruction && !END_INSTRUCTIONS.include?(instruction[2])
      name = instruction[2]
      arguments = instruction[3]

      if BLOCK_INSTRUCTIONS.include?(name)
        block_position = position + 1
        map.send(name, *arguments) do
          result, position = execute(instructions, block_position, map)
        end
      else
        result = map.send(name, *arguments)
      end

      instruction = instructions[position += 1]
    end

    [result, position]
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

  def extends_path
    contexts.last.extends_path
  end

  def extends_path=(val)
    contexts.last.extends_path = val
  end

  def in_block(name)
    blocks.push(Block.new(name))

    yield

    blocks.pop.tap do |block|
      exec.local_variable_set(block.name, block.buffer)
      heap[block.name] = block.buffer
    end.buffer
  end

  def for(value, key, obj)
    old_value = exec.local_variable_get(value) if exec.local_variables.include?(value)
    old_key = exec.local_variable_get(key) if key && exec.local_variables.include?(key)

    exec.eval(obj).each.with_index do |item, index|
      exec.local_variable_set(value, item)
      exec.local_variable_set(key, index) if key
      yield
    end

    exec.local_variable_set(value, old_value) if old_value
    exec.local_variable_set(key, old_key) if old_key
  end

  def capture(str)
    !blocks.empty? ? blocks.last.capture(str) : self.buffer += str.to_s
  end

  def include(path, data = {})
    contexts.push(Context.new(data))
    prepare_exec
    cache.retrieve(path, template_path).call(self).tap { contexts.pop }
  end

  def extend
    path = extends_path
    contexts.push(Context.new(content: buffer))
    prepare_exec
    self.buffer = cache.retrieve(path, template_path).call(self).tap { contexts.pop }
  end

  def put(varname)
    capture(exec.eval(varname)) if exec.local_variables.include?(varname.to_sym)
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
