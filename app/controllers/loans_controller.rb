class LoansController < ApplicationController
  before_action :set_loan, except: [:index, :new, :create]
  before_action :authorize_admin, only: [:approve, :admin_reject, :propose_adjustment]
  
  def index
    if current_account.admin?
      @loans = Loan.all
    else
      @loans = current_account.taken_loans
    end
  end

  def show
  end

  def new
    @loan = current_account.taken_loans.build
  end

  def create
    @loan = current_account.taken_loans.build(loan_params)
    @loan.lender = Account.admin.first

    if @loan.save
      redirect_to @loan, notice: "Loan request submitted!"
    else
      render :new, status: :unprocessable_entity
    end
  end

  def update
    case params[:type]
    when "admin_adjustment"
      @loan.status = :waiting_for_adjustment_acceptance
      flash[:notice] = "Admin proposed adjustment!"
    when "user_adjustment"
      @loan.status = :readjustment_requested
      flash[:notice] = "User requested readjustment!"
    else
      flash[:notice] = "Loan terms updated."
    end

    if @loan.update(loan_params)
      redirect_to @loan
    else
      render :edit
    end
  end  

  # For Users
  def confirm
    if @loan.approved? || @loan.waiting_for_adjustment_acceptance?
      @loan.accept
      redirect_to @loan, notice: "Loan opened!"
    else
      redirect_to @loan, alert: "Loan is not in approved or waiting state."
    end
  end

  def repay
    if @loan.open?
      @loan.repayment
      redirect_to @loan, notice: "Loan repaid!"
    else
      redirect_to @loan, alert: "Loan is not open yet."
    end
  end

  def reject
    if @loan.approved? || @loan.waiting_for_adjustment_acceptance?
      @loan.rejected!
      redirect_to @loan, notice: "Loan rejected."
    else
      redirect_to @loan, alert: "Loan is not in approved or waiting state."
    end
  end

  def request_readjustment
    if @loan.waiting_for_adjustment_acceptance?
      redirect_to edit_loan_path(@loan, type: :user_adjustment)
    else
      redirect_to @loan, alert: "Loan is not in waiting state."
    end
  end


  # For Admin
  def approve
    if @loan.requested? || @loan.readjustment_requested?
      @loan.approved!
      redirect_to @loan, notice: "Loan approved. Waiting user confirmation."
    else
      redirect_to @loan, alert: "Loan is not in requested state."
    end
  end

  def admin_reject
    if @loan.requested? || @loan.readjustment_requested?
      @loan.rejected!
      redirect_to @loan, notice: "Loan request rejected."
    else
      redirect_to @loan, alert: "Loan is not in requested state."
    end
  end

  def propose_adjustment
    if @loan.requested? || @loan.readjustment_requested?
      redirect_to edit_loan_path(@loan, type: :admin_adjustment)
    else
      redirect_to @loan, alert: "Loan is not in requested state."
    end
  end

  private

  def set_loan
    @loan = Loan.find(params[:id])
  end
  
  def loan_params
    params.require(:loan).permit(:amount, :interest_rate)
  end

  def authorize_admin
    redirect_to loans_path, alert: "Not authorized." unless current_account.admin?
  end
end
