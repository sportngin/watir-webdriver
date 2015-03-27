require 'logger'
# encoding: utf-8
module Watir

  #
  # Base class for HTML elements.
  #
  class Element
    extend AttributeHelper

    include Exception
    include Container
    include EventuallyPresent

    #
    # temporarily add :id and :class_name manually since they're no longer specified in the HTML spec.
    #
    # @see http://html5.org/r/6605
    # @see http://html5.org/r/7174
    #
    # TODO: use IDL from DOM core - http://dvcs.w3.org/hg/domcore/raw-file/tip/Overview.html
    #
    attribute String, :id, :id
    attribute String, :class_name, :className

    attr_accessor :selector

    def initialize(parent, selector)
      @parent   = parent
      @selector = selector
      @element  = nil
      @logger = Logger.new(STDOUT)
      @logger.datetime_format = '%y-%m-#d %H:%M:%S'
      @logger.formatter = proc do |severity, datetime, _, msg|
        format = "[#{severity} - #{datetime}] - Watir - #{msg}"
        if ARGV.any? { |arg| arg == 'h' } #HTML output
          "#{format}<br>"
        else
          "#{format}\n"
        end
      end

      @timer = Watir::Wait::Timer.new
      @default_timeout = 20


      unless @selector.kind_of? Hash
        raise ArgumentError, "invalid argument: #{selector.inspect}"
      end
    end

    #
    # Returns true if element exists.
    #
    # @return [Boolean]
    #

    def exists?
      assert_exists
      true
    rescue UnknownObjectException, UnknownFrameException
      false
    end
    alias_method :exist?, :exists?

    def inspect
      if @selector.has_key?(:element)
        '#<%s:0x%x located=%s selector=%s>' % [self.class, hash*2, !!@element, '{:element=>(webdriver element)}']
      else
        '#<%s:0x%x located=%s selector=%s>' % [self.class, hash*2, !!@element, selector_string]
      end
    end

    #
    # Returns true if two elements are equal.
    #
    # @example
    #   browser.text_field(:name => "new_user_first_name") == browser.text_field(:name => "new_user_first_name")
    #   #=> true
    #

    def ==(other)
      other.kind_of?(self.class) && wd == other.wd
    end
    alias_method :eql?, :==

    def hash
      @element ? @element.hash : super
    end

    #
    # Returns the text of the element.
    #
    # @return [String]
    #

    def text
      self.wait_until_present(@default_timeout)
      assert_exists
      @logger.info "Retrieving element text: #{@selector}."
      element_call { @element.text }
    end

    #
    # Returns tag name of the element.
    #
    # @return [String]
    #

    def tag_name
      assert_exists
      element_call { @element.tag_name.downcase }
    end

    #
    # Clicks the element, optionally while pressing the given modifier keys.
    # Note that support for holding a modifier key is currently experimental,
    # and may not work at all.
    #
    # @example Click an element
    #   browser.element(:name => "new_user_button").click
    #
    # @example Click an element with shift key pressed
    #   browser.element(:name => "new_user_button").click(:shift)
    #
    # @example Click an element with several modifier keys pressed
    #   browser.element(:name => "new_user_button").click(:shift, :control)
    #
    # @param [:shift, :alt, :control, :command, :meta] Modifier key(s) to press while clicking.
    #

    def click(*modifiers)
      self.wait_until_present(@default_timeout)
      assert_exists
      assert_enabled

      element_call do
        if modifiers.any?
          assert_has_input_devices_for "click(#{modifiers.join ', '})"

          action = driver.action
          modifiers.each { |mod| action.key_down mod }
          action.click @element
          modifiers.each { |mod| action.key_up mod }

          @logger.info "Clicking element with modifiers #{modifiers.join ', '}: #{@selector.to_s}"
          action.perform

        else
          @logger.info "Clicking element: #{@selector.to_s}"
          @element.click
        end
      end

      run_checkers
    end

    #
    # Double clicks the element.
    # Note that browser support may vary.
    #
    # @example
    #   browser.element(:name => "new_user_button").double_click
    #

    def double_click
      self.wait_until_present(@default_timeout)
      assert_exists
      assert_has_input_devices_for :double_click

      @logger.info "Double clicking element: #{@selector}."
      element_call { driver.action.double_click(@element).perform }
      run_checkers
    end

    #
    # Right clicks the element.
    # Note that browser support may vary.
    #
    # @example
    #   browser.element(:name => "new_user_button").right_click
    #

    def right_click
      self.wait_until_present(@default_timeout)
      assert_exists
      assert_has_input_devices_for :right_click

      @logger.info "Right clicking element: #{@selector}."
      element_call { driver.action.context_click(@element).perform }
      run_checkers
    end

    #
    # Moves the mouse to the middle of this element.
    # Note that browser support may vary.
    #
    # @example
    #   browser.element(:name => "new_user_button").hover
    #

    def hover
      self.wait_until_present(@default_timeout)
      assert_exists
      assert_has_input_devices_for :hover

      @logger.info "Hovering over element: #{@selector}."
      element_call { driver.action.move_to(@element).perform }
    end

    #
    # Drag and drop this element on to another element instance.
    # Note that browser support may vary.
    #
    # @example
    #   a = browser.div(:id => "draggable")
    #   b = browser.div(:id => "droppable")
    #   a.drag_and_drop_on b
    #

    def drag_and_drop_on(other)
      self.wait_until_present(@default_timeout)
      @timer.wait(@default_timeout) { other.present? }

      assert_is_element other
      assert_exists
      assert_has_input_devices_for :drag_and_drop_on

      @logger.info "Draging element #{@selector} on element #{other.selector}."

      element_call do
        driver.action.
               drag_and_drop(@element, other.wd).
               perform
      end
    end

    #
    # Drag and drop this element by the given offsets.
    # Note that browser support may vary.
    #
    # @example
    #   browser.div(:id => "draggable").drag_and_drop_by 100, -200
    #
    # @param [Fixnum] right_by
    # @param [Fixnum] down_by
    #

    def drag_and_drop_by(right_by, down_by)
      self.wait_until_present(@default_timeout)
      assert_exists
      assert_has_input_devices_for :drag_and_drop_by

      @logger.info "Draging element #{@selector} to the right #{right_by} and down #{down_by}."

      element_call do
        driver.action.
               drag_and_drop_by(@element, right_by, down_by).
               perform
      end
    end

    #
    # Flashes (change background color far a moment) element.
    #
    # @example
    #   browser.text_field(:name => "new_user_first_name").flash
    #

    def flash
      self.wait_until_present(@default_timeout)
      background_color = style("backgroundColor")
      element_color = driver.execute_script("arguments[0].style.backgroundColor", @element)

      10.times do |n|
        color = (n % 2 == 0) ? "red" : background_color
        driver.execute_script("arguments[0].style.backgroundColor = '#{color}'", @element)
      end

      driver.execute_script("arguments[0].style.backgroundColor = arguments[1]", @element, element_color)

      self
    end

    #
    # Returns value of the element.
    #
    # @return [String]
    #

    def value
      attribute_value('value') || ''
    rescue Selenium::WebDriver::Error::InvalidElementStateError
      ''
    end

    #
    # Returns given attribute value of element.
    #
    # @example
    #   browser.a(:id => "link_2").attribute_value "title"
    #   #=> "link_title_2"
    #
    # @param [String] attribute_name
    # @return [String, nil]
    #

    def attribute_value(attribute_name)
      assert_exists
      element_call { @element.attribute attribute_name }
    end

    #
    # Returns outer (inner + element itself) HTML code of element.
    #
    # @example
    #   browser.div(:id => 'foo').outer_html
    #   #=> "<div id=\"foo\"><a href=\"#\">hello</a></div>"
    #
    # @return [String]
    #

    def outer_html
      assert_exists
      element_call { execute_atom(:getOuterHtml, @element) }.strip
    end

    alias_method :html, :outer_html

    #
    # Returns inner HTML code of element.
    #
    # @example
    #   browser.div(:id => 'foo').inner_html
    #   #=> "<a href=\"#\">hello</a>"
    #
    # @return [String]
    #

    def inner_html
      assert_exists
      element_call { execute_atom(:getInnerHtml, @element) }.strip
    end

    #
    # Sends sequence of keystrokes to element.
    #
    # @example
    #   browser.text_field(:name => "new_user_first_name").send_keys "Watir", :return
    #
    # @param [String, Symbol] *args
    #

    def send_keys(*args)
      self.wait_until_present(@default_timeout)
      assert_exists
      assert_writable
      element_call { @element.send_keys(*args) }
    end

    #
    # Focuses element.
    # Note that Firefox queues focus events until the window actually has focus.
    #
    # @see http://code.google.com/p/selenium/issues/detail?id=157
    #

    def focus
      self.wait_until_present(@default_timeout)
      assert_exists
      element_call { driver.execute_script "return arguments[0].focus()", @element }
    end

    #
    # Returns true if this element is focused.
    #
    # @return [Boolean]
    #

    def focused?
      assert_exists
      element_call { @element == driver.switch_to.active_element }
    end

    #
    # Simulates JavaScript events on element.
    # Note that you may omit "on" from event name.
    #
    # @example
    #   browser.button(:name => "new_user_button").fire_event :click
    #   browser.button(:name => "new_user_button").fire_event "mousemove"
    #   browser.button(:name => "new_user_button").fire_event "onmouseover"
    #
    # @param [String, Symbol] event_name
    #

    def fire_event(event_name)
      assert_exists
      event_name = event_name.to_s.sub(/^on/, '').downcase

      element_call { execute_atom :fireEvent, @element, event_name }
    end

    #
    # Returns parent element of current element.
    #

    def parent
      assert_exists

      e = element_call { execute_atom :getParentElement, @element }

      if e.kind_of?(Selenium::WebDriver::Element)
        Watir.element_class_for(e.tag_name.downcase).new(@parent, :element => e)
      end
    end

    #
    # @api private
    #

    def driver
      @parent.driver
    end

    #
    # @api private
    #

    def wd
      assert_exists
      @element
    end

    #
    # Returns true if this element is visible on the page.
    #
    # @return [Boolean]
    #

    def visible?
      assert_exists
      element_call { @element.displayed? }
    end

    #
    # Returns true if the element exists and is visible on the page.
    #
    # @return [Boolean]
    # @see Watir::Wait
    #

    def present?
      exists? && visible?
    rescue Selenium::WebDriver::Error::StaleElementReferenceError, UnknownObjectException
      # if the element disappears between the exists? and visible? calls,
      # consider it not present.
      false
    end

    #
    # Returns given style property of this element.
    #
    # @example
    #   browser.button(:value => "Delete").style           #=> "border: 4px solid red;"
    #   browser.button(:value => "Delete").style("border") #=> "4px solid red"
    #
    # @param [String] property
    # @return [String]
    #

    def style(property = nil)
      if property
        assert_exists
        element_call { @element.style property }
      else
        attribute_value("style").to_s.strip
      end
    end

    #
    # Runs checkers.
    #

    def run_checkers
      @parent.run_checkers
    end

    #
    # Cast this Element instance to a more specific subtype.
    #
    # @example
    #   browser.element(:xpath => "//input[@type='submit']").to_subtype
    #   #=> #<Watir::Button>
    #

    def to_subtype
      elem = wd()
      tag_name = elem.tag_name.downcase

      klass = nil

      if tag_name == "input"
        klass = case elem.attribute(:type)
          when *Button::VALID_TYPES
            Button
          when 'checkbox'
            CheckBox
          when 'radio'
            Radio
          when 'file'
            FileField
          else
            TextField
          end
      else
        klass = Watir.element_class_for(tag_name)
      end

      klass.new(@parent, :element => elem)
    end

    #
    # Returns browser.
    #
    # @return [Watir::Browser]
    #

    def browser
      @parent.browser
    end

  protected

    def assert_exists
      begin
        assert_not_stale if @element ||= @selector[:element]
      rescue UnknownObjectException => ex
        raise ex if @selector[:element] || !Watir.always_locate?
      end

      @element ||= locate

      unless @element
        raise UnknownObjectException, "unable to locate element, using #{selector_string}"
      end
    end

    def assert_not_stale
      @parent.assert_not_stale
      @parent.switch_to! if @parent.is_a? IFrame
      @element.enabled? # do a staleness check - any wire call will do.
    rescue Selenium::WebDriver::Error::ObsoleteElementError => ex
      # don't cache a stale element - it will never come back
      reset!
      raise UnknownObjectException, "#{ex.message} - #{selector_string}"
    end

    def reset!
      @element = nil
    end

    def locate
      @parent.is_a?(IFrame) ? @parent.switch_to! : @parent.assert_exists
      locator_class.new(@parent.wd, @selector, self.class.attribute_list).locate
    end

  private

    def locator_class
      ElementLocator
    end

    def selector_string
      @selector.inspect
    end

    def attribute?(attribute)
      assert_exists
      element_call do
        !!execute_atom(:getAttribute, @element, attribute.to_s.downcase)
      end
    end

    def assert_enabled
      unless element_call { @element.enabled? }
        raise ObjectDisabledException, "object is disabled #{selector_string}"
      end
    end

    def assert_writable
      assert_enabled

      if respond_to?(:readonly?) && readonly?
        raise ObjectReadOnlyException, "object is read only #{selector_string}"
      end
    end

    def assert_has_input_devices_for(name)
      unless driver.kind_of? Selenium::WebDriver::DriverExtensions::HasInputDevices
        raise NotImplementedError, "#{self.class}##{name} is not supported by this driver"
      end
    end

    def assert_is_element(obj)
      unless obj.kind_of? Watir::Element
        raise TypeError, "execpted Watir::Element, got #{obj.inspect}:#{obj.class}"
      end
    end

    def element_call
      yield
    rescue Selenium::WebDriver::Error::StaleElementReferenceError
      raise unless Watir.always_locate?
      reset!
      assert_exists
      retry
    end

    def method_missing(meth, *args, &blk)
      method = meth.to_s
      if method =~ ElementLocator::WILDCARD_ATTRIBUTE
        attribute_value(method.gsub(/_/, '-'), *args)
      else
        super
      end
    end

  end # Element
end # Watir
