# frozen_string_literal: true

class Beard; end

require 'beard/vm'
require 'beard/compiler'
require 'beard/map'
require 'beard/cache'

class Beard
  attr_reader :templates, :root, :cache

  def initialize(options)
    @templates = options[:templates]
    @root = options[:root]
    @cache = Cache.new(templates)
  end

  def render(path, data = {})
    cache.retrieve(path).call(VM.new(data, cache))
  end
end
