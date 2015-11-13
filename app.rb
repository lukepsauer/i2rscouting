class ScoutingApp < Sinatra::Base
  use Rack::Session::Cookie, :expire_after => 3600*24
  helpers do
    def login?
      @members = User.all
      if session[:id] == nil
        redirect '/user/login'
      end
      @teamSearch= Team.order(:number)
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
    team.climbers = params[:kick]

    if params[:file] != nil
      name = Cloudinary::Uploader.upload(params[:file][:tempfile], :quality=>100, :height=>300, :crop=>:lfill, :gravity=>:xy_center, api_key: '547116342579632', api_secret: 'm1obtBUPF4sbG5nNaLCttadv6tU', cloud_name: 'i2rscout')
      team.photos = name["url"]
    end
    team.save

    if !checkbox(params[:completed])
      redirect "/team/#{team.id}"
    else
      redirect "/teams"
    end
  end
  get '/teams' do
    login?
    @teams = Team.order(:number)
    @teamsSelected = Team.exclude(:picked => nil || 0).order(:picked)
    erb :teams
  end

  post '/user/create' do
    if params[:password].to_s == params[:passwordcheck].to_s && User.where(:name => params[:username]).count == 0
      u = User.new
      u.name = params[:username]
      u.password = params[:password].to_s
      u.save
      u = User.first(:name => params[:username])
      session[:id] = u.id
      redirect '/'
    else
      redirect '/user/signup'
    end
  end

=begin
  post '/sorted' do

      if params['autoclimbers']
        @teams = Team.exclude(:climbersShelter => 0 || nil)
      else
        @teams = Team.exclude(:climbersShelter => 1 || 2)
      end
      if params['autoheight'] != nil || 0
        @teams = @teams.where(:autoHeight => params['autoheight'])
      end
      if params['beacon']
        @teams = @teams.exclude(:beacon => false || nil)
      end
      if params['delays']
        @teams = @teams.exclude(:delays => false || nil)
      end
    if params["debris"] != nil || 0
      @teams = @teams.where(:debris => params["debris"])
    end
    if params["climb"] != nil || 0
      @teams = @teams.where(:climb => params["climb"])
    end
    if params["climbers"] != nil || 0
      @teams = @teams.where(:climbers => params["climbers"])
    end
    if params['bar']
      @teams = @teams.exclude(:bar => false || nil)
    end
    @teamsSelected = Team.exclude(:picked => nil || 0).order(:picked)
    login?
    erb :teams
end
=end
  get '/todo' do
    login?
    @teamsDone = Team.where(:teamMate => session[:id]).where(:completed => true).order(:number)
    @teams = Team.where(:teamMate => session[:id]).where(:completed => false).order(:number)

    erb :todo
  end

  get '/user/login' do
    @members = User.all
    erb :login
  end
  if ENV['SIGNUP']
    get '/user/signup' do
      @members = User.all
      erb :signup
    end
  end

  get '/team/:id' do
    login?
    @users = User.all
    @team = Team.first(:id => params[:id])
    erb :teamedit
  end

  get '/teams/other' do
    login?
    @teamsDone = Team.where(:completed => true).order(:number)
    @teams = Team.where(:completed => false).order(:number)
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
      redirect '/teams'
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
      session[:id] = u.name
      redirect '/'
    else
      redirect '/user/login'
    end
  end

  get '/user/signout' do
    session[:id] = nil
    redirect '/user/login'
  end
end
