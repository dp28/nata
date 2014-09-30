require 'spec_helper'

describe "StaticPages" do

  subject { page }

  shared_examples_for "a static page" do |name, path_extension|
    path_extension ||= name.downcase
    before { visit "/#{path_extension}" }
    it { should have_content(name) }
    it { should have_title(full_title(name)) }  
  end

  describe "Home page" do 
    before { visit root_path }
    it { should have_content("Nata") }
    it { should have_title(full_title) }
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
