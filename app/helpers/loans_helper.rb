module LoansHelper
  def version_author(version)
    account = Account.find_by(id: version.whodunnit)
    account ? "#{account.email} (#{account.role})" : "System"
  end
end
