module Manage
  class UsersController < BaseController
    before_action :set_user, only: [:show, :edit, :update, :destroy, :toggle_active]

    def index
      @users = User.order(created_at: :desc)
      @users = @users.where(role: params[:role]) if params[:role].present?
      @users = @users.page(params[:page]).per(20)
    end

    def show
      @campaigns = @user.creator? && @user.author ? @user.author.campaigns.order(created_at: :desc) : Campaign.none
    end

    def new
      @user = User.new
      @authors = Author.order(:full_name)
    end

    def create
      @user = User.new(user_params)
      if @user.save
        role_label = @user.admin? ? 'Team member' : 'Creator'
        redirect_to manage_users_path, notice: "#{role_label} created — #{@user.email}"
      else
        @authors = Author.order(:full_name)
        flash.now[:alert] = @user.errors.full_messages.join(', ')
        render :new, status: :unprocessable_entity
      end
    end

    def edit
      @authors = Author.order(:full_name)
    end

    def update
      # Allow blank password to mean "keep current"
      filtered = user_params.to_h
      filtered.delete('password') if filtered['password'].blank?
      filtered.delete('password_confirmation') if filtered['password_confirmation'].blank?

      if @user.update(filtered)
        redirect_to manage_user_path(@user), notice: 'User updated.'
      else
        @authors = Author.order(:full_name)
        flash.now[:alert] = @user.errors.full_messages.join(', ')
        render :edit, status: :unprocessable_entity
      end
    end

    def destroy
      if @user == current_user
        redirect_to manage_users_path, alert: "You can't delete your own account."
        return
      end
      @user.destroy
      redirect_to manage_users_path, notice: 'User deleted.'
    end

    def toggle_active
      if @user == current_user
        redirect_to manage_user_path(@user), alert: "You can't disable your own account."
        return
      end
      @user.update!(active: !@user.active?)
      status = @user.active? ? 'enabled' : 'disabled'
      redirect_to manage_user_path(@user), notice: "Account #{status}."
    end

    private

    def set_user
      @user = User.find(params[:id])
    end

    def user_params
      params.require(:user).permit(:first_name, :last_name, :email, :password, :password_confirmation, :role, :account_id, :account_type)
    end
  end
end
