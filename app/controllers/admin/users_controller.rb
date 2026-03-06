# frozen_string_literal: true

module Admin
  class UsersController < BaseController
    def index
      @pagy, @users = pagy(policy_scope(User))
    end

    def show
      @user = User.find(params[:id])
      authorize @user
    end
  end
end
