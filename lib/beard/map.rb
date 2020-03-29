# frozen_string_literal: true

class Beard::Compiler::Map
  class << self
    def run(tag)
      send(tag[2], *tag[3])
    end

    def set_path(path)
      [
        "_vm.path = '#{path}'"
      ]
    end

    def buffer
      [
        '_vm.buffer'
      ]
    end

    def capture(str)
      [
        "_vm.capture(\"#{str}\")"
      ]
    end

    def eval(str)
      [
        "_vm.capture(_vm.eval('#{str.gsub("'", "\\\\'")}'))"
      ]
    end

    def block(block_name)
      [
        "_vm.in_block('#{block_name}') do"
      ]
    end

    def block_end
      [
        'end'
      ]
    end

    def include(path, data)
      [
        "_vm.capture(_vm.include(#{path}, #{data.inspect} || {}))"
      ]
    end
  end
end
