# typed: false
require "sorbet-runtime"

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

        module_eval(&fn) if block_given?
      end

      types.each do |type, config|
        klass = Class.new(T::Struct) do
          include container_module
          include DeconstructableSorbetStruct

          config.each do |field, type|
            const field, type
          end
        end

        container_module.const_set(type.capitalize, klass)
      end

      container_module
    end
  end
end
