# frozen_string_literal: true

class Beard::Compiler
  class Map
    class << self
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

  STATEMENT = /{{\s*([\S\s(?!}})]+?)\s*}}(?!\})/.freeze
  EXPS = {
    block: /^block\s+(.[^}]*)/,
    block_end: /^endblock$/
  }.freeze

  attr_reader :template, :path, :statements

  def initialize(template, path)
    @template = template
    @path = path
    @statements = []
  end

  def capture(str, quoted = true)
    str = quoted ? "\"#{str}\"" : "_context.eval('#{str}')"
    "_context.capture(#{str})"
  end

  def capture_previous(template, previous, current)
    current > previous ? capture(template[previous..current - 1]) : ''
  end

  def compile_tag(tag)
    match = EXPS.detect { |_, exp| exp =~ tag }
    match ? Map.send(match[0], *Regexp.last_match.captures) : capture(tag, false)
  end

  def compile
    last_match = 0
    lines = template.gsub(STATEMENT).map do
      statement = Regexp.last_match
      [
        capture_previous(template, last_match, statement.begin(0)),
        compile_tag(statement[1])
      ].tap { last_match = statement.end(0) }
    end

    lines << capture(template[last_match..template.length - 1]) if last_match < (template.length - 1)

    fn = <<~STR
      proc do |_context|
        _context.path = '#{path}'

        #{lines.flatten.join("\n")}

        _context.buffer
      end
    STR

    # puts fn

    eval(fn) # rubocop:disable Security/Eval
  end
end
