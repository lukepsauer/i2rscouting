class ScoutingApp < Sinatra::Base
  use Rack::Session::Cookie, :expire_after => 3600*24

  helpers do
    def login?
      @members = User.all
      if session[:id] == nil
        redirect '/user/login'
      end
    end

    def checkbox(test)
      if test == "on"
        return true
      else
        return false
      end
    end
  end

# READ
  get '/' do
    login?
    erb :index
  end

  post '/team/update/:id' do
    team = Team.first(:id => params[:id])
    team.teamMate = params[:member]
    team.picked = params[:select]
    team.debris = params[:debris]
    team.climb = params[:climb]
    team.bar = checkbox(params[:bar])
    team.reliability = params[:reliability]
    team.autoHeight = params[:autoHeight]
    team.climbersShelter = params[:climbers]
    team.beacon = checkbox(params[:beacon])
    team.delays = checkbox(params[:delays])
    team.name = params[:name]
    team.number = params[:number]
    team.completed = checkbox(params[:completed])
    team.save


=begin

    if params[:file] != nil
      name = Cloudinary::Uploader.upload(params[:file][:tempfile], api_key: '775114683723846', api_secret: 'q0ldPxQtX4QdbVmbqo2bH8rrCU8', cloud_name: 'i2r')
      filetype = params[:file][:filename].split('.')[1]
      team.photos = cl_image_tag("#{name["public_id"]}.#{filetype}")
    end
    team.save

=begin
    if params[:file] != nil
      file = params[:file][:tempfile]

      File.open("./public/team/photos/#{team.number}.#{filetype}", 'wb') do |f|
        f.write(file.read)
      end
    end
=end
  if !checkbox(params[:completed])
    redirect "/team/#{team.id}"
  else
    redirect "/teams"
  end
  end
  get '/teams' do
    login?
    @teams = Team.all
    @teamsSelected = Team.exclude(:picked => nil || 0)
    erb :teams
  end

  post '/user/create' do
    if params[:password].to_s == params[:passwordcheck].to_s && User.where(:name => params[:username]).count == 0
      u = User.new
      u.name = params[:username]
      u.password = params[:password].to_s
      u.save
      u = User.first(:name => params[:username])
      session['id'] = u.id
      redirect '/'
    else
      redirect '/user/signup'
    end
  end

  get '/todo' do
    login?
    @teamsDone = Team.where(:teamMate => session[:id]).where(:completed => true)
    @teams = Team.where(:teamMate => session[:id]).where(:completed => false)

    erb :todo
  end

  get '/user/login' do
    @members = User.all
    erb :login
  end

  get '/user/signup' do
    @members = User.all
    erb :signup
  end

  get '/team/:id' do
    login?
    @users = User.all
    @team = Team.first(:id => params[:id])
    erb :teamedit
  end

  get '/teams/other' do
    login?
    @teamsDone = Team.where(:completed => true)
    @teams = Team.where(:completed => false)
    erb :todo
  end

  post '/team/post' do
    if Team.where(:number => params[:number]).count == 0
      u = Team.new
      u.name = params[:name].to_s
      u.number = params[:number].to_i
      u.teamMate = params[:member].to_s
      u.photos = '/team/photos/square-image.png'
      u.completed = false
      u.save
      redirect '/teams'
    else
      redirect '/user/signup'
    end
  end
  get '/team/delete/:id' do
    Team.first(:id => params[:id]).delete
    redirect '/teams'
  end

  post '/user/authenticate' do
    u = User.first(Sequel.ilike(:name, params[:username]))
    if u == nil
      redirect '/user/login'
    elsif u.password.to_s == params[:password]
      session['id'] = u.name
      redirect '/'
    else
      redirect '/user/login'
    end
  end

  get '/user/signout' do
    session['id'] = nil
    redirect '/user/login'
  end
end
