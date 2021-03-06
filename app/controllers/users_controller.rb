class UsersController < ApplicationController

	before_action :find_user, except: [:index, :new, :create]
	before_action :correct_user, only: [:edit, :update, :manage]
	before_action :find_recent_articles, only: [:show, :about_me]
	before_action :set_side_bar, only: [:show]

	def index
		@users = User.all
		@user = current_user
	end

	def new
		@user = User.new
	end

	def create
		@user = User.new(user_params)
		if @user.save
			log_in(@user)
			flash[:success] = "修改或完善個人資料"
			redirect_to edit_user_path(@user)
		else
			render :new
		end		
	end

	def show
		if params[:tag]
			@articles = @user.tags.find_by(name: params[:tag]).articles.published.page(params[:page]).per(5)
		else	
			@articles = @user.articles.find_by_date(*@query_date).page(params[:page]).per(5)
		end	
	end

	def edit
	end

	def update
		  if @user.update_attributes (user_params)
				flash[:success] = "更新已儲存"
		    redirect_to user_path(current_user)
		  else
		  	render :edit
		  end	
	end

	def about_me
	end	

	def manage
		case params[:state]
		when nil
			select_articles = @user.articles.except_recycling_bin
		when "1", "2", "3"	
		  select_articles = @user.articles.find_by_state(params[:state].to_i)
		when "trash"  
			select_articles = @user.articles.find_by_state([11, 12, 13])
		end

		@articles = select_articles.page(params[:page]).per(25)
		@articles_by_year = @articles.group_by { |article| article.created_at.beginning_of_year}
		@tags = @user.tags.all
	end

	private
		def user_params
			a = [:name, :email, :password, :password_confirmation, :title, :about_me, :gravatar, 
				   :event_days, :article_days, :today, :picture, :picture_cache, :remove_picture ]
			
			params[:user].permit(*a)
		end

		def find_user
			@user = User.find(params[:id])
		end

    def correct_user
    	@user = User.find(params[:id])
    	unless current_user?(@user)
    		flash[:danger] = "無此權限"
    		redirect_to root_path
    	end
    end


end



