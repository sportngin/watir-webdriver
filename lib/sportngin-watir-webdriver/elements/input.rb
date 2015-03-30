# encoding: utf-8
module SportNginWatir
  class Input < HTMLElement

    alias_method :readonly?, :read_only?

    #
    # Returns true if input is enabled.
    #
    # @return [Boolean]
    #

    def enabled?
      !disabled?
    end

  end # Input
end # SportNginWatir
