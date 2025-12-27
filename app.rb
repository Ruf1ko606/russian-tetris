# frozen_string_literal: true
# encoding: UTF-8

require 'dotenv/load'
require 'sinatra'
require 'sinatra/reloader' if development?
require 'json'
require 'pg'
require_relative 'lib/tetris_game'

enable :sessions
set :session_secret, 'f9a7e3b1c8d2f0a9e8d7c6b5a4f3e2d1c0b9a8f7e6d5c4b3a2f1e0d9c8b7a6f5a4b3c2d1e0f9a8b7c6d5e4f3a2b1c0d9e8f7a6b5c4d3e2f1a0b9c8d7e6f5a4b3'
set :default_encoding, 'UTF-8'

def db_connection
  conn = PG.connect(
    host: ENV['DB_HOST'] || 'localhost', 
    user: ENV['DB_USER'] || 'postgres', 
    password: ENV['DB_PASSWORD'] || 'your_password_here', 
    dbname: ENV['DB_NAME'] || 'tetris_db'
  )
  conn.set_client_encoding('UTF8')
  conn
end

get '/' do
  erb :index
end

post '/start_game' do
  session.clear
  game = TetrisGame.new
  session[:game_state] = game.state_for_session
  content_type :json
  game.state_for_client.to_json
end

post '/move' do
  state = session[:game_state]
  return status 400 if state.nil?
  
  game = TetrisGame.from_state(state)
  params = JSON.parse(request.body.read)
  game.handle_action(params['action'])

  session[:game_state] = game.state_for_session
  content_type :json
  game.state_for_client.to_json
end

post '/game_over' do
  state = session[:game_state]
  return status 400 if state.nil?
  
  game = TetrisGame.from_state(state)
  params = JSON.parse(request.body.read)
  player_name = (params['name'].nil? || params['name'].to_s.strip.empty?) ? 'Anonymous' : params['name'].strip

  begin
    client = db_connection
    client.exec_params(
      'INSERT INTO leaderboard (player_name, score, level, lines) VALUES ($1, $2, $3, $4)',
      [player_name, game.score, game.level, game.lines_cleared]
    )
    client.close
    content_type :json
    { status: 'ok', message: 'Score saved' }.to_json
  rescue PG::Error => e
    halt 500, { status: 'error', message: "Database error: #{e.message}" }.to_json
  rescue => e
    halt 500, { status: 'error', message: "Error saving score: #{e.message}" }.to_json
  end
end

get '/leaderboard' do
  begin
    client = db_connection
    result = client.exec('SELECT player_name, score, level, lines FROM leaderboard ORDER BY score DESC LIMIT 10')
    @leaders = result.to_a
    client.close
    erb :leaderboard
  rescue PG::Error => e
    @error = "Ошибка подключения к базе данных: #{e.message.force_encoding('UTF-8')}".force_encoding('UTF-8')
    @leaders = []
    erb :leaderboard
  rescue => e
    @error = "Ошибка при загрузке таблицы лидеров: #{e.message.force_encoding('UTF-8')}".force_encoding('UTF-8')
    @leaders = []
    erb :leaderboard
  end
end

