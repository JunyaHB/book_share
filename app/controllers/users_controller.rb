class UsersController < ApplicationController

  before_action :authenticate_user, {only: [:show, :edit, :update]}
  before_action :forbid_login_user, {only: [:new, :create, :login_form, :login]}
  before_action :ensure_correct_user, {only: [:edit, :update]}
  def index
  	@user = User.all.order(created_at: :desc)
  end

  def show
  	@user = User.find_by(id: params[:id])
  end

  def new
  	@user = User.new
  end

  def create
  	@user = User.new(
  		name: params[:user_name],
  		email: params[:email],
  		image_name: "default_user.png",
  		password: params[:password]
  		)
  	if @user.save
  		session[:user_id] = @user.id
  		redirect_to("/users/#{@user.id}/show")
  	else
  		render("/users/new")
  	end
  end

  def edit
  	@user = User.find_by(id: params[:id])
  end

  def update
  	@user = User.find_by(id: params[:id])
  	@user.name = params[:user_name]
  	@user.email = params[:email]
  	if params[:image]
	  	@user.image_name = "#{@user.id}.jpg"
  		image = params[:image]
  		File.binwrite("public/user_images/#{@user.image_name}",image.read)
  	end
  	if @user.save
  		flash[:notice] = "ユーザ情報を編集しました"
  		redirect_to("/users/#{@user.id}/show")
  	else
  		render("/users/edit")
  	end
  end

  def login_form

  end

  def login
  	@user = User.find_by(
  		email: params[:email]
  		)
  	if @user && @user.authenticate(params[:password])
  		session[:user_id] = @user.id
  		flash[:notice] = "ログインしました"
  		redirect_to("/posts/index")
  	else
  		@error_message ="メールアドレスまたはパスワードが間違っています"
  		@email = params[:email]
  		@password = params[:password]
  		render("users/login_form")
  	end
  end

  def logout
  	session[:user_id] = nil
  	flash[:notice] = "ログアウトしました"
  	redirect_to("/login")
  end

  def ensure_correct_user
    if @current_user.id != params[:id].to_i
      flash[:notice] = "権限がありません"
      redirect_to("/posts/index")
    end
  end

  def twitter_create
    # request.env['omniauth.auth']にユーザのTwitter認証情報が格納されている
    user_data = request.env['omniauth.auth']

    @user = User.find_by(
      email: user_data[:info][:urls][:Twitter]
      )
    if @user
      session[:user_id] = @user.id
      flash[:notice] = "ログインしました"
      redirect_to("/posts/index")

    else

      @user = User.new(
        name: user_data[:info][:name],
        email: user_data[:info][:urls][:Twitter],
        twitter_image: user_data[:info][:image],
        password: user_data[:info][:nickname]
        )
      if @user.save
        session[:user_id] = @user.id
        flash[:notice] = "ログインしました"
        redirect_to("/posts/index")
      else
        render("/users/new")
      end

    end

  end

end