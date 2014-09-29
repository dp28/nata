require 'spec_helper'

describe "StaticPages" do

  shared_examples_for "a static page" do |name, path_extension|
    path_extension ||= name.downcase
    before { visit "/#{path_extension}" }
    it { expect(page).to have_content(name) }
    it { expect(page).to have_title("#{name} | Nata") }  
  end

  describe "Home page" do 
    before { visit root_path }
    it { expect(page).to have_content("Nata") }
    it { expect(page).to have_title("Nata") }
  end 

  describe "Help page" do
    it_should_behave_like "a static page", "Help"
  end 

  describe "About page" do
    it_should_behave_like "a static page", "About"
  end

  describe "Contact page" do
    it_should_behave_like "a static page", "Contact"
  end
end
