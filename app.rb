require 'sinatra'
require 'dotenv/load'
require 'tilt/erubis'
require 'json'
require 'pony'
require 'unirest'

require_relative 'lib/database_persistence'

configure do
  enable :sessions
  set :session_secret, ENV['SESSION_SECRET']
  set :erb, :escape_html => true
end

configure(:development) do
  require 'sinatra/reloader'
  also_reload './lib/database_persistence.rb'
end


before do
  @storage = DatabasePersistence.new(logger)
end

def recaptcha_passed?
  recaptcha_response = Unirest.post(
  'https://www.google.com/recaptcha/api/siteverify',
  headers: { 'Accept' => 'application/json' },
  parameters: {
  secret: ENV['RECAPTCHA_SECRET'],
  response: params['g-recaptcha-response']
  }
  )
  recaptcha_response.body['success']
end

def send_email(from_name, from_email, body, subject = 'C2M2 Message')
  Pony.mail(
  to: ENV['MAIL_TO'],
  'reply_to' => "#{from_name} <#{from_email}>",
  subject: subject,
  body: body
  )
end

get '/' do
  erb :home
end

get '/vision' do
  erb :vision
end

get '/why' do
  erb :why
end

get '/suggest' do
  erb :suggest
end

post '/suggest' do
  if recaptcha_passed?
    message = "Name: #{params[:rs_name]}\nEmail: #{params[:rs_email]}\n"
    message << "Composer(s) Concerned: #{params[:rs_composer]}\n" if params[:rs_composer]
    message << "Major Work(s) and/or Film(s) Concerned: #{params[:rs_works]}\n" if params[:rs_works]
    message << "Link to Resource: #{params[:rs_link]}\n" if params[:rs_link]
    message << "Location (name of library, repository, database...): #{params[:rs_location]}\n" if params[:rs_location]
    message << "Comments: #{params[:rs_comments]}\n" if params[:rs_comments]

    send_email(params[:rs_name],
               params[:rs_email],
               message,
               'C2M2 Resource Suggestion')

    session[:message] = 'Your message was sent successfully. Thank you!'
    redirect '/'
  else
    session[:message] = 'Your message could not be sent. Please try again.'
    erb :suggest
  end
end

get '/contact' do
  erb :contact
end

post '/contact' do
  if recaptcha_passed?
    message = "Name: #{params[:contact_name]}\nEmail: #{params[:contact_email]}"
    message << "\nMessage: #{params[:contact_message]}" if params[:contact_message]

    send_email(params[:contact_name],
               params[:contact_email],
               message)

    session[:message] = 'Your message was sent successfully. Thank you!'
    redirect '/'
  else
    session[:message] = 'Your message could not be sent. Please try again.'
    erb :contact
  end
end

get '/search' do
  erb :search
end

get '/work/:work_id' do
  @result = @storage.work_details(params[:work_id].to_i)
  erb :work
end

get '/browse' do
  @heading = 'Browse'
  @info = 'Listings sorted alphabetically by work title.'
  @result = @storage.browse_all
  erb :browse
end

get '/composer/:id' do
  @info = 'Listings sorted alphabetically by work title.'
  @heading, @result = @storage.browse_composer(params[:id].to_i)
  erb :browse
end

get '/director/:id' do
  @info = 'Listings sorted alphabetically by work title.'
  @heading, @result = @storage.browse_director(params[:id].to_i)
  erb :browse
end

get '/country/:id' do
  @info = 'Listings sorted alphabetically by work title.'
  @heading, @result = @storage.browse_country(params[:id].to_i)
  erb :browse
end

get '/media_type/:id' do
  @info = 'Listings sorted alphabetically by work title.'
  @heading, @result = @storage.browse_media_type(params[:id].to_i)
  erb :browse
end

get '/collection/:id' do
  @info = 'Listings sorted alphabetically by work title.'
  @heading, @result = @storage.browse_collection(params[:id].to_i)
  erb :browse
end

get '/material_format/:id' do
  @info = 'Listings sorted alphabetically by work title.'
  @heading, @result = @storage.browse_material_format(params[:id].to_i)
  erb :browse
end

get '/cataloger/:id' do
  @info = 'Listings sorted alphabetically by work title.'
  @heading, @result = @storage.browse_cataloger(params[:id].to_i)
  erb :browse
end

not_found do
  redirect '/'
end
