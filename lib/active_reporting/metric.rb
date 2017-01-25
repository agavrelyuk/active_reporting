require 'forwardable'
module ActiveReporting
  class Metric
    extend Forwardable
    def_delegators :@fact_model, :model
    attr_reader :fact_model, :name, :dimensions, :dimension_filter, :aggregate

    def initialize(name, fact_model:, aggregate: :count, dimensions: [], dimension_filter: {})
      @name             = name.to_sym
      @fact_model       = fact_model
      @dimension_filter = dimension_filter
      @aggregate        = aggregate
      determine_dimensions Array(dimensions)
      check_dimension_filter
    end

    private ####################################################################

    def determine_dimensions(dimensions)
      @dimensions = []
      dimensions.each do |dim|
        dimension_name, label = if dim.is_a?(Hash)
                                  Array(dim)
                                else
                                  [dim, nil]
                                end
        found_dimension = @fact_model.dimensions[dimension_name.to_sym]
        raise UnknownDimension.new(dim, @fact_model) unless found_dimension.present?
        @dimensions << ReportingDimension.new(found_dimension, label: label)
      end
    end

    def check_dimension_filter
      @dimension_filter.each do |name, _|
        @fact_model.find_dimension_filter(name)
      end
    end
  end
end
