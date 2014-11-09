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
    it { should have_content(I18n.t("name")) }
    it { should have_title(full_title) }

    context "for signed-in users" do
      let(:user) { FactoryGirl.create(:user) }
      before do
        user.add_task content: "Lorem ipsum"
        user.add_task content: "Dolor sit amet"
        sign_in user
        visit root_path
      end

      it "should render the user's feed" do
        user.feed.each do |item|
          expect(page).to have_selector("li##{item.id}", text: item.content)
        end
      end
    end
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
