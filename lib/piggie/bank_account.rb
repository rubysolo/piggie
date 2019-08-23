require "mechanize"

module Piggie
  class BankAccount
    attr_reader :agent, :bank_details, :routing_number

    def self.find(routing_number)
      new(routing_number).tap(&:find)
    end

    def initialize(routing_number)
      @bank_details = {}
      @routing_number = standardize(routing_number)
      @agent = Mechanize.new
      agent.user_agent_alias = random_user_agent
    end

    def find
      agree_to_terms
      search_for_routing_number
      @bank_details = get_bank_details
    end

    def valid?
      bank_details.key?("name")
    end

    private

    def standardize(input)
      routing_number = input.to_s

      # restore stripped leading zeros
      if routing_number.match?(/\A\d+\z/)
        routing_number = routing_number.rjust(9, "0")
      end

      routing_number
    end

    def random_user_agent
      user_agents = Mechanize::AGENT_ALIASES.keys - ['Mechanize']
      user_agents.sample
    end

    def agree_to_terms
      @current_page = agent.get("https://www.frbservices.org/EPaymentsDirectory/search.html")

      @current_page.form_with(name: "acceptedForm") do |form|
        button = form.button_with(value: "Agree")
        @current_page = agent.submit(form, button)
      end
    end

    def search_for_routing_number
      @current_page.form_with(id: "searchForm") do |form|
        form.aba = routing_number
        button = form.button_with(value: "Search")
        @current_page = agent.submit(form, button)
      end
    end

    def get_bank_details
      detail_link = @current_page.links.find { |link| link.text.gsub(/\D/, "") == routing_number }
      return {} unless detail_link

      @current_page = agent.click(detail_link)
      (@current_page / "li[id]").each_with_object({}) do |e, h|
        e.at_css('strong').remove
        h[e.attr(:id).delete_prefix("detail_")] = e.text.strip
      end
    end
  end
end
