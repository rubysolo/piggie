require "piggie/bank_account"
require "piggie/version"

module Piggie
  def self.find(routing_number)
    Piggie::BankAccount.find(routing_number)
  end
end
