# frozen_string_literal: true

class Beard; end

require 'beard/context'
require 'beard/compiler'

class Beard
  attr_reader :templates, :root, :fns

  def initialize(options)
    @templates = options[:templates]
    @root = options[:root]
    @fns = {}
  end

  def render(path, data = {})
    compiled(path).call(Context.new(data))
  end

  private

  def compiled(path, parent_path = '')
    path = resolve_path(path, parent_path)
    fns[path] ||= Compiler.new(templates[path], path).compile
  end

  def resolve_path(path, parent_path)
    return path if path[0] == '/'
    return File.expand_path(root, path.sub('~', '.')) if path[0] == '~'

    Pathname.new("#{parent_path.sub(%r{/[^/]+$}, '')}/#{path}").to_path
  end
end
