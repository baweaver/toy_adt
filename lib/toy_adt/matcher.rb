# typed: false
# frozen_string_literal: true

require "set"

module ToyAdt
  class Matcher
    extend T::Sig

    POSITIONAL_ARGS = Set[:req, :opt, :rest]
    KEYWORD_ARGS    = Set[:keyreq, :key, :keyrest]
    BLOCK_ARGS      = Set[:block]

    def initialize(from:, &fn)
      @from = from
      @fields = from::FIELDS
      @sub_classes = @fields.to_h { [_1, from.const_get(_1.capitalize)] }

      create_branch_methods

      instance_eval(&fn) if block_given?
    end

    def else(&fn)
      @else_fn = fn
    end

    def call(input)
      # Find the subclass the input matches to
      branch_name, _ = @sub_classes.find do |_, klass|
        matches_type?(klass, input)
      end

      # If there are none either hit the else or fail hard
      if branch_name.nil?
        return @else_fn.call(input) if @else_fn
        T.absurd(input)
      end

      # All values to compare against conditions
      values = input.deconstruct_keys(nil)

      # Try to find the first matching branch function via
      # conditions:
      #
      #     value.match do |m|
      #       m.some(value: 0..5) {}
      #       m.some {}
      #       m.else {}
      #     end
      #
      # In this case a "Some" type with a value matching will hit
      # first. Granted less specific branches going first means
      # those get hit first, so not recommended.
      _, branch_fn = @branches.find do |branch_condition, _|
        name, conditions = branch_condition

        # First thing is the key is a tuple of subclass / branch
        # name, the second part is the condition if there are any.
        branch_name == name && conditions.all? { |k, condition|
          matches_type?(condition, values[k])
        }
      end

      return branch_fn.call(input) if branch_fn
      return @else_fn.call(input) if @else_fn

      T.absurd(input)
    end

    alias_method :===, :call

    def to_proc
      -> input { call(input) }
    end

    # Making this respond to both `===` and the sorbet type
    # validation variants.
    private def matches_type?(type, value)
      type === value || sorbet_is_a?(type, value)
    end

    private def sorbet_is_a?(type, value)
      T::Types::Base === type && type.valid?(value)
    end

    private def create_branch_methods
      @branches = {}

      @fields.each do |field|
        define_singleton_method(field) do |**conditions, &fn|
          param_type  = get_param_type(fn)
          param_names = fn.parameters.map(&:last)

          # Trying to make it play nicely with pattern matching
          # semantics, hitting both positional and keywords but
          # also no-args.
          @branches[[field, conditions]] = -> input do
            case param_type
            when :keyword
              fn.call(**input.deconstruct_keys(param_names))
            when :positional
              fn.call(*input.deconstruct) # Should probably disable this
            when :none
              fn.call
            end
          end
        end
      end
    end

    private def get_param_type(fn)
      param_types = fn.parameters.map(&:first)

      has_positional = param_types.any?(POSITIONAL_ARGS)
      has_keywords   = param_types.any?(KEYWORD_ARGS)
      has_block      = param_types.any?(BLOCK_ARGS)

      if has_block
        raise ArgumentError, "Cannot use function arguments"
      end

      if has_positional && has_keywords
        raise ArgumentError, "Cannot have both positional and keyword arguments"
      end

      return :keyword if has_keywords
      return :positional if has_positional

      :none
    end
  end
end
