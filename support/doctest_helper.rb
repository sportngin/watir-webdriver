require 'watir-webdriver'
require 'spec/watirspec/lib/watirspec'

#
# 1. If example does not start browser, start new one, reuse until example
#    finishes and close after
# 2. If example starts browser and assigns it to local variable `browser`,
#    it will still be closed
#

def browser
  @browser ||= SportNgin::Watir::Browser.start(WatirSpec.url_for('forms_with_input_elements.html'))
end

YARD::Doctest.configure do |doctest|
  doctest.skip 'SportNgin::Watir::Browser.start'
  doctest.skip 'SportNgin::Watir::Cookies'
  doctest.skip 'SportNgin::Watir::Element#to_subtype'
  doctest.skip 'SportNgin::Watir::Option'
  doctest.skip 'SportNgin::Watir::Screenshot'
  doctest.skip 'SportNgin::Watir::Window#size'
  doctest.skip 'SportNgin::Watir::Window#position'

  %w[text ok close exists?].each do |name|
    doctest.before("SportNgin::Watir::Alert##{name}") do
      browser.goto WatirSpec.url_for('alerts.html')
      browser.button(:id => 'alert').click
    end
  end

  doctest.before('SportNgin::Watir::Alert#set') do
    browser.goto WatirSpec.url_for('alerts.html')
    browser.button(:id => 'prompt').click
  end

  doctest.before('SportNgin::Watir::CheckBox#set') do
    browser.goto WatirSpec.url_for('forms_with_input_elements.html')
    checkbox = browser.checkbox(:id => 'new_user_interests_cars')
  end

  %w[SportNgin::Watir::Browser#execute_script SportNgin::Watir::Element#drag_and_drop].each do |name|
    doctest.before(name) do
      browser.goto WatirSpec.url_for('drag_and_drop.html')
    end
  end

  doctest.before('SportNgin::Watir::Element#attribute_value') do
    browser.goto WatirSpec.url_for('non_control_elements.html')
  end

  %w[inner_html outer_html].each do |name|
    doctest.before("SportNgin::Watir::Element##{name}") do
      browser.goto WatirSpec.url_for('inner_outer.html')
    end
  end

  %w[SportNgin::Watir::HasWindow SportNgin::Watir::Window#== SportNgin::Watir::Window#use].each do |name|
    doctest.before(name) do
      browser.goto WatirSpec.url_for('window_switching.html')
      browser.a(:id => 'open').click
    end
  end

  doctest.after do
    browser.quit
    @browser = nil
  end
end

if ENV['TRAVIS']
  ENV['DISPLAY'] = ':99.0'
end
