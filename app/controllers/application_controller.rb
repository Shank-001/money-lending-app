class ApplicationController < ActionController::Base
  before_action :authenticate_account!
  before_action :set_paper_trail_whodunnit

  private

  def user_for_paper_trail
    current_account&.id
  end  
end
