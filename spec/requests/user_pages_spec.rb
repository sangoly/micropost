require 'spec_helper'

describe "user pages" do
  
  subject { page }

  describe "sign up" do
    before { visit signup_path }
    let(:submit) { 'Create my account' }

    describe "with invalid register infomation" do
      it "should not register" do
        expect { click_button(submit) }.not_to change(User, :count)
      end

      describe "after submition" do
        before { click_button submit }
        it { should have_title("Sign up") }
        it { should have_content("error") }
      end
    end

    describe "with valid register infomation" do
      before do
        fill_in "Name",       with: "Example user"
        fill_in "Email",      with: "user@example.com"
        fill_in "Password",   with: "foobar"
        fill_in "Confirm",    with: "foobar"
      end
      
      it "should register" do
        expect do
          click_button(submit)
        end.to change(User, :count).by(1)
      end

      describe "after register new user" do
        before { click_button(submit) }
        let(:user) { User.find_by(email: "user@example.com") }
        
        it { should have_link('Sign out') }
        it { should have_title(user.name) }
        it { should have_selector('div.alert.alert-success', text: 'Welcome') }
      end
    end

    it { should have_content('Sign up') }
    it { should have_title(full_title('Sign up')) }
  end

  describe "profile page" do
    let(:user) { FactoryGirl.create(:user) }
  	before { visit user_path(user) }
  	it { should have_content(user.name) }
  	it { should have_title(user.name) }
  end
end
