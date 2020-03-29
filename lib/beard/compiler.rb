# frozen_string_literal: true

class Beard::Compiler
  STATEMENT = /{{\s*([\S\s(?!}})]+?)\s*}}(?!\})/.freeze
  EXPS = {
    include: /^include\s+([^,]+)(?:,\s*([\s\S]*))?$/,
    block: /^block\s+(.[^}]*)/,
    block_end: /^endblock$/
  }.freeze

  attr_reader :template, :path, :statements

  def initialize(template, path)
    @template = template
    @path = path
    @statements = []
  end

  def statement_tag(match)
    tag = EXPS.detect { |_, exp| exp =~ match[1] }&.dig(0)

    if tag
      arguments = $~.captures
    else
      arguments = [match[1]]
      tag = :eval
    end

    [match.begin(0), match.end(0), tag, arguments]
  end

  def capture_tag(start, finish)
    return nil if start >= finish
    [start, finish, :capture, [template[start..finish]]]
  end

  def compile
    statements = template.gsub(STATEMENT).map { statement_tag(Regexp.last_match) }
    statements << [template.length, template.length, :buffer, []]

    template = statements.reduce([[0, 0, :set_path, [path]]]) do |tags, tag|
      tags << capture_tag(tags.last[1], tag[0] - 1)
      tags << tag
    end.compact.map { |tag| Map.run(tag) }.flatten

    fn = <<~STR
      proc do |_vm|
        #{template.join("\n")}
      end
    STR

    # puts fn

    eval(fn) # rubocop:disable Security/Eval
  end
end
