require 'spec_helper'

describe "StaticPages" do

  shared_examples_for "a static page" do |name, path_extension=nil|
    path_extension ||= name.downcase

    it "should have the content '#{name}'" do
      visit "/static_pages/#{path_extension}"
      expect(page).to have_content(name)
    end

    it "should have the title '#{name} | Nata'" do
      visit "/static_pages/#{path_extension}"
      expect(page).to have_title("#{name} | Nata")
    end
  end

  describe "Home page" do
    it_should_behave_like "a static page", "Home"
  end

  describe "Help page" do
    it_should_behave_like "a static page", "Help"
  end

  describe "About page" do
    it_should_behave_like "a static page", "About"
  end
end
