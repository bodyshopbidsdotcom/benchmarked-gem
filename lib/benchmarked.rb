require 'benchmarked/version'
require 'benchmarked/class_methods'
require 'benchmark'

module Benchmarked
  class << self
    attr_writer :notifier

    def configure
      yield(self)
    end

    def benchmark_and_notify(obj, method_name, args)
      result = nil

      if @notifier.nil?
        result = yield
      else
        measurement = Benchmark.measure { result = yield }
        @notifier.benchmark_taken(measurement, obj, method_name, args, result)
      end

      result
    end

    def clean_configuration
      @notifier = nil
    end
  end
end

Module.send(:include, Benchmarked::ClassMethods)
