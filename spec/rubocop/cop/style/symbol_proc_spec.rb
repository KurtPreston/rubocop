# encoding: utf-8

require 'spec_helper'

describe RuboCop::Cop::Style::SymbolProc do
  subject(:cop) { described_class.new }

  it 'registers an offense for a block with paratermess method call on param' do
    inspect_source(cop, 'coll.map { |e| e.upcase }')
    expect(cop.offenses.size).to eq(1)
    expect(cop.messages)
      .to eq(['Pass `&:upcase` as an argument to `map` instead of a block.'])
  end

  it 'registers an offense for a block when method in body is unary -/=' do
    inspect_source(cop, ['something.map { |x| -x }'])
    expect(cop.offenses.size).to eq(1)
    expect(cop.messages)
      .to eq(['Pass `&:-@` as an argument to `map` instead of a block.'])
  end

  it 'accepts method receiving another argument beside the block' do
    inspect_source(cop, ['File.open(file) { |f| f.readlines }'])

    expect(cop.offenses).to be_empty
  end

  it 'accepts block with more than 1 arguments' do
    inspect_source(cop, ['something { |x, y| x.method }'])

    expect(cop.offenses).to be_empty
  end

  it 'accepts block with no arguments' do
    inspect_source(cop, ['something { x.method }'])

    expect(cop.offenses).to be_empty
  end

  it 'accepts block with more than 1 expression in body' do
    inspect_source(cop, ['something { |x| x.method; something_else }'])

    expect(cop.offenses).to be_empty
  end

  it 'accepts block when method in body is not called on block arg' do
    inspect_source(cop, ['something { |x| y.method }'])

    expect(cop.offenses).to be_empty
  end

  it 'autocorrects alias with symbols as proc' do
    corrected = autocorrect_source(cop, ['coll.map { |s| s.upcase }'])
    expect(corrected).to eq 'coll.map(&:upcase)'
  end
end
