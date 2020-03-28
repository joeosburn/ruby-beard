# frozen_string_literal: true

require 'beard'

describe 'Templates' do
  it 'renders content' do
    beard = Beard.new(
      templates: {
        '/content' => 'some content'
      }
    )
    expect(beard.render('content')).to eq('some content')
  end

  it 'renders blocks' do
    engine = Beard.new(
      templates: {
        '/block' => '{{block footer}}a footer{{endblock}}some info - {{footer}}'
      }
    )
    expect(engine.render('block')).to eq('some info - a footer')
  end
end
