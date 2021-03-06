# frozen_string_literal: true

require_relative "base"

module Model
  class Goal < Model::Base
    # @return [String]
    attr_reader :name

    # @return [String]
    attr_reader :description

    # @return [String]
    attr_reader :date

    # @return [Integer]
    attr_reader :rating

    def initialize(name:, description:, date:, rating:)
      @name        = name
      @description = description
      @date        = date
      @rating      = rating
    end
  end
end
