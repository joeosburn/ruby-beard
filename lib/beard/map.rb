# frozen_string_literal: true

class Beard::Compiler::Map
  class << self
    def run(tag)
      send(tag[2], *tag[3])
    end

    def set_path(path)
      [
        "_context.path = '#{path}'"
      ]
    end

    def buffer
      [
        '_context.buffer'
      ]
    end

    def capture(str)
      [
        "_context.capture(\"#{str}\")"
      ]
    end

    def eval(str)
      [
        "_context.capture(_context.eval('#{str}'))"
      ]
    end

    def block(block_name)
      [
        "_context.in_block('#{block_name}') do"
      ]
    end

    def block_end
      [
        'end'
      ]
    end
  end
end
