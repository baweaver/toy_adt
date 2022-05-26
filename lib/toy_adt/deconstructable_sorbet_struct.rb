# typed: false
require "sorbet-runtime"

module ToyAdt
  module DeconstructableSorbetStruct
    extend T::Sig

    sig { returns(T::Array[T.untyped]) }
    def deconstruct
      properties.map { send(_1) }
    end

    sig {
      params(
        keys: T.nilable(T::Array[Symbol])
      ).returns(T::Hash[Symbol, T.untyped])
    }
    def deconstruct_keys(keys)
      return properties.to_h { |k| [k, send(k)] } if keys.empty? || keys.nil?

      (properties & keys).to_h { |k| [k, send(k)] }
    end

    sig { returns(T::Array[Symbol]) }
    def properties
      self.class.props.keys
    end
  end
end
