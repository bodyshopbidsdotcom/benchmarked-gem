module Benchmarked
  module ClassMethods
    def handle_with_benchmark(method_name)
      # Inspired by
      # https://github.com/collectiveidea/delayed_job/blob/73bd1b50e719b336b70fcbb8dc4a37ec9b2f6f35/lib/delayed/message_sending.rb#L34-L62
      aliased_method_name = method_name.to_s.sub(/([?!=])$/, '')
      punctuation = $1
      with = "#{aliased_method_name}_with_benchmark#{punctuation}"
      without = "#{aliased_method_name}_without_benchmark#{punctuation}"

      define_method(with) do |*args, &block|
        ret = nil

        Benchmarked.benchmark_and_notify(self, method_name, args) do
          ret = send(without, *args, &block)
        end

        ret
      end

      alias_method without, method_name
      alias_method method_name, with

      if public_method_defined?(without)
        public with, method_name
      elsif protected_method_defined?(without)
        protected with, method_name
      elsif private_method_defined?(without)
        private with, method_name
      end
    end
  end
end
