require 'sinatra'
require 'sinatra/reloader' if development?
require 'dotenv/load'
require 'tilt/erubis'
require 'json'
require 'graphql'
require 'pony'
require 'unirest'

configure do
  enable :sessions
  set :session_secret, ENV['SESSION_SECRET']
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

