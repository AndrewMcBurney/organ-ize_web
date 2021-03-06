# frozen_string_literal: true

require "dogapi"
require "pp"

module Datadog
  class Downtime
    attr_reader :dog

    def initialize
      api_key = ENV["DATADOG_API_KEY"]
      application_key = ENV["DATADOG_APP_KEY"]
      @dog = Dogapi::Client.new(api_key, application_key)
    end

    # Generates Downtimes using the Datadog API.
    #
    # @param [Integer] number: The number of downtimes to generate.
    def generate!(number:)
      number.times do
        downtime = generate_downtime!
        dog.schedule_downtime(
          downtime.scope,
          start: downtime.start_ts,
          monitor_tags: downtime.monitor_tags,
          end: downtime.end_ts,
          recurrence: downtime.recurrence
        )
      end
    end

    # Creates a number of Downtimes using the API.
    #
    # @param [Array[Model::Downtime]] downtimes
    def create!(downtimes:)
      downtimes.each do |downtime|
        dog.schedule_downtime(
          downtime.scope,
          start: downtime.start_ts,
          monitor_tags: downtime.monitor_tags,
          end: downtime.end_ts,
          recurrence: downtime.recurrence
        )
      end
    end

    # Cancels all downtimes for a particular scope using the API.
    def delete_all!
      downtimes = get_all[1]
      downtime_names = downtimes.map.with_index { |m, i| "#{i + 1}: scope:#{m['scope']} | id:#{m['id']}" }.join("\n")

      UI.success("Warning! This will delete the following downtimes: ")
      UI.message(downtime_names)
      response = UI.select("Are you sure you want to proceed?", %w[y n])

      if response == "n"
        UI.message("Exiting without canceling downtimes!")
        exit
      end

      downtimes.each do |d|
        dog.cancel_downtime(d["id"])
      end
    end

    # Returns all downtimes for a scope from the API.
    def get_all(active_only: false)
      options = {
        "current_only" => active_only
      }
      downtimes = dog.get_all_downtimes(options: options)
      pp downtimes
      downtimes
    end

    private

    def generate_downtime!
      start_ts = Time.now.to_i
      end_ts = start_ts + (rand(1..3) * 60 * 60)

      Model::Downtime.new(
        scope: "*",
        monitor_tags: ["github:armcburney"],
        start_ts: start_ts,
        end_ts: end_ts
      )
    end
  end
end
