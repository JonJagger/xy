# frozen_string_literal: true
require_relative 'xy_scores'
require 'sinatra/base'
require 'sinatra/contrib'
require 'sprockets'
require 'json'

class XY < Sinatra::Base
  register Sinatra::Contrib

  set :port, ENV['PORT']
  set :environment, Sprockets::Environment.new
  environment.append_path('assets/stylesheets')
  environment.append_path('assets/javascripts')
  environment.css_compressor = :scss

  def initialize(app = nil)
    super(app)
  end

  get '/assets/*' do
    env['PATH_INFO'].sub!('/assets', '')
    settings.environment.call(env)
  end

  get '/xy' do
    erb :xy
  end

  post '/scores' do
    a = decisions('wa', 'a')
    b = decisions('wb', 'b')
    c = decisions('wc', 'c')
    @scores = JSON.pretty_generate(xy_scores(sentence, profound, a,b,c))
    erb :scores
  end

  private

  def decisions(is_word, s)
    is_word = params[is_word] === 'true'
    s = params[s]
    is_word ? word(s) : blah(s)
  end

  def sentence
    params['sentence'] === 'true'
  end

  def profound
    params['profound'] === 'true'
  end

end
