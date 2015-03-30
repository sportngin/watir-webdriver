require File.expand_path('watirspec/spec_helper', File.dirname(__FILE__))

describe SportNginWatir::Browser do

  before do
    browser.goto SportNginWatirSpec.url_for("special_chars.html", :needs_server => true)
  end

  it "finds elements with single quotes" do
    expect(browser.div(:text => "single 'quotes'")).to exist
  end

end
