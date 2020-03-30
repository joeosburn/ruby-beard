# frozen_string_literal: true

class Beard::VM::Map
  attr_reader :vm

  def initialize(vm)
    @vm = vm
  end

  def finish
    vm.extend if vm.extends_path
    vm.buffer
  end

  def extends(path)
    vm.extends_path = vm.eval(path)
  end

  def set_template_path(path)
    vm.template_path = path
  end

  def buffer
    vm.buffer
  end

  def capture(str)
    vm.capture(str)
  end

  def capture_eval(str)
    capture(vm.eval(str))
  end

  def block(name)
    vm.in_block(name) do
      yield
    end
  end

  def include(args)
    capture(vm.include(*vm.eval("[#{args}]")))
  end

  def put(varname)
    vm.put(varname)
  end
end
