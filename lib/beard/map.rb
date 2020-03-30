# frozen_string_literal: true

class Beard::VM::Map
  attr_reader :vm

  def initialize(vm)
    @vm = vm
  end

  def set_path(path)
    vm.path = path
  end

  def buffer
    vm.buffer
  end

  def capture(str)
    vm.capture(str)
  end

  def eval(str)
    capture(vm.eval(str))
  end

  def block(name)
    vm.in_block(name) do
      yield
    end
  end

  def include(path, data)
    capture(vm.include(vm.eval(path), data || {}))
  end
end
