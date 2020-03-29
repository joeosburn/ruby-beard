# frozen_string_literal: true

class Beard::Cache
  attr_reader :templates, :fns

  def initialize(templates)
    @templates = templates
    @fns = {}
  end

  def retrieve(path, parent_path = '')
    path = resolve_path(path, parent_path)
    fns[path] ||= Beard::Compiler.new(templates[path], path).compile
  end

  private

  def resolve_path(path, parent_path)
    return path if path[0] == '/'
    return File.expand_path(root, path.sub('~', '.')) if path[0] == '~'

    Pathname.new("#{parent_path.sub(/\/[^\/]+$/, '')}/#{path}").to_path
  end
end
