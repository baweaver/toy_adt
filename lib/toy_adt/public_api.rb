# typed: false
require "sorbet-runtime"
require "set"

module ToyAdt
  module PublicApi
    extend T::Sig

    sig {
      params(
        config: T.any(Class, T::Types::Base),
        fn: T.nilable(T.proc.void)
      ).returns(Class)
    }
    def type(**config, &fn)
      Class.new(T::Struct) do
        include DeconstructableSorbetStruct

        config.each do |field, type|
          const field, type
        end

        module_eval(&fn) if block_given?
      end
    end

    sig {
      params(
        types: T::Hash[Symbol, T.any(Class, T::Types::Base)],
        fn: T.proc.void
      ).returns(Module)
    }
    def sum(**types, &fn)
      container_module = Module.new do
        extend T::Helpers
        sealed!

        const_set(:FIELDS, types.keys)

        module_eval(&fn) if block_given?

        def self.match(&fn) = Matcher.new(from: self, &fn)
        def self.match_call(input, &fn) = match(&fn).call(input)
      end

      types.each do |type, config|
        klass = Class.new(T::Struct) do
          include container_module
          include DeconstructableSorbetStruct

          const_set(:CONTAINER, container_module)

          config.each do |field, type|
            const field, type
          end

          def match(&fn) = self.class::CONTAINER.match(&fn).call(self)
        end

        container_module.const_set(type.capitalize, klass)
        container_module.define_method(type) do
          klass
        end
      end

      container_module
    end
  end
end
