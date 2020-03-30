# frozen_string_literal: true

require 'beard'
require 'benchmark'

describe 'Templates' do
  it 'renders content' do
    beard = Beard.new(
      templates: {
        '/content' => 'some content'
      }
    )
    expect(beard.render('content')).to eq('some content')
  end

  it 'includes templates' do
    engine = Beard.new(
      templates: {
        '/content' => 'some content',
        '/view' => "header {{include 'content'}} footer"
      }
    )
    expect(engine.render('view')).to eq('header some content footer')
  end

  it 'includes templates with dynamic paths' do
    engine = Beard.new(
      templates: {
        '/view' => %{header
          {{include partial}}
          {{include \"/includes/\#{support}\"}}
          {{include \"/includes/\#{other.gsub('_', '-')}\"}}
        },
        '/includes/content' => 'Partial Content',
        '/includes/footer' => 'Footer',
        '/includes/other-content' => 'Content!'
      }
    )

    data = {partial: '/includes/content', support: 'footer', other: 'other_content'}
    expect(engine.render('view', data).gsub(/\s+/, ' ').strip).to eq('header Partial Content Footer Content!')
  end

  it 'renders blocks' do
    engine = Beard.new(
      templates: {
        '/block' => '{{block footer}}a footer{{endblock}}some info - {{footer}}'
      }
    )
    expect(engine.render('block')).to eq('some info - a footer')
  end

  it 'renders blocks inside blocks' do
    engine = Beard.new(
      templates: {
        '/block' => "
          {{block footer}}
            a footer
            {{block sub}}
              sub{{block name}}bill{{endblock}}info
            {{endblock}}
          {{endblock}}
          {{footer}} -- {{name}} -- {{sub}}"
      }
    )
    expect(engine.render('block').gsub(/\s+/, ' ')).to eq(' a footer -- bill -- subinfo ')
  end
end
