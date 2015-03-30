require 'sportngin-watir-webdriver'
require 'spec/watirspec/lib/watirspec'

#
# 1. If example does not start browser, start new one, reuse until example
#    finishes and close after
# 2. If example starts browser and assigns it to local variable `browser`,
#    it will still be closed
#

def browser
  @browser ||= SportNginWatir::Browser.start(SportNginWatirSpec.url_for('forms_with_input_elements.html'))
end

YARD::Doctest.configure do |doctest|
  doctest.skip 'SportNginWatir::Browser.start'
  doctest.skip 'SportNginWatir::Cookies'
  doctest.skip 'SportNginWatir::Element#to_subtype'
  doctest.skip 'SportNginWatir::Option'
  doctest.skip 'SportNginWatir::Screenshot'
  doctest.skip 'SportNginWatir::Window#size'
  doctest.skip 'SportNginWatir::Window#position'

  %w[text ok close exists?].each do |name|
    doctest.before("SportNginWatir::Alert##{name}") do
      browser.goto SportNginWatirSpec.url_for('alerts.html')
      browser.button(:id => 'alert').click
    end
  end

  doctest.before('SportNginWatir::Alert#set') do
    browser.goto SportNginWatirSpec.url_for('alerts.html')
    browser.button(:id => 'prompt').click
  end

  doctest.before('SportNginWatir::CheckBox#set') do
    browser.goto SportNginWatirSpec.url_for('forms_with_input_elements.html')
    checkbox = browser.checkbox(:id => 'new_user_interests_cars')
  end

  %w[SportNginWatir::Browser#execute_script SportNginWatir::Element#drag_and_drop].each do |name|
    doctest.before(name) do
      browser.goto SportNginWatirSpec.url_for('drag_and_drop.html')
    end
  end

  doctest.before('SportNginWatir::Element#attribute_value') do
    browser.goto SportNginWatirSpec.url_for('non_control_elements.html')
  end

  %w[inner_html outer_html].each do |name|
    doctest.before("SportNginWatir::Element##{name}") do
      browser.goto SportNginWatirSpec.url_for('inner_outer.html')
    end
  end

  %w[SportNginWatir::HasWindow SportNginWatir::Window#== SportNginWatir::Window#use].each do |name|
    doctest.before(name) do
      browser.goto SportNginWatirSpec.url_for('window_switching.html')
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
