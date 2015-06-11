module SportNginWatir
  module UserEditable

    #
    # Clear the element, the type in the given value.
    #
    # @param [String, Symbol] *args
    #

    def set(*args)
      self.wait_until_present(@default_timeout)
      clear
      element_call { @element.send_keys(*args) }
    end
    alias_method :value=, :set

    #
    # Appends the given value to the text in the text field.
    #
    # @param [String, Symbol] *args
    #

    def append(*args)
      self.wait_until_present(@default_timeout)
      send_keys(*args)
    end
    alias_method :<<, :append

    #
    # Clears the text field.
    #

    def clear
      self.wait_until_present(@default_timeout)
      assert_exists
      assert_writable
      element_call { @element.clear }
    end

  end # UserEditable
end # SportNginWatir
