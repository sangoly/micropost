require 'spec_helper'

describe "user pages" do
  
  subject { page }

  describe "index" do
    let(:user) { FactoryGirl.create(:user) }
    before(:each) do
      sign_in user
      visit users_path
    end

    it { should have_title('All users') }
    it { should have_content('All users') }

    describe "pagination" do
      before(:all) { 30.times { |n| FactoryGirl.create(:user) } }
      after(:all) { User.delete_all }
    
      it { should have_selector('div.pagination') }
      it "should list each user" do
        User.paginate(page: 1).each do |user|
          expect(page).to have_selector('li', text: user.name)
        end
      end
    end

    describe "delete link" do

      it { should_not have_link('delete') }

      describe "as a admin user" do
        let(:admin) { FactoryGirl.create(:admin) }

        before do
          sign_in admin
          visit users_path
        end

        it { should have_link('delete', href: user_path(User.first)) }

        it "should be able to delete another user" do
          expect do
            click_link('delete', match: :first)
          end.to change(User, :count).by(-1)
        end

        it { should_not have_link('delete', href: user_path(admin)) }
      end
    end
  end

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
    let!(:m1) { FactoryGirl.create(:micropost, user: user, content: 'Foo') }
    let!(:m2) { FactoryGirl.create(:micropost, user: user, content: 'Bar') }

  	before { visit user_path(user) }

  	it { should have_content(user.email) }
  	it { should have_title(user.name) }

    describe "microposts" do
      it { should have_content(m1.content) }
      it { should have_content(m2.content) }
      it { should have_content(user.microposts.count) }
    end

    describe "follow/unfollow button" do
      let(:other_user) { FactoryGirl.create(:user) }
      before { sign_in user }

      describe "follow a user" do
        before { visit user_path(other_user) }

        it "should increament the followed user count" do
          expect { click_button 'follow' }.to change(user.followed_users, :count).by(1)
        end

        it "should increment the other user's followers count" do
          expect { click_button 'follow' }.to change(other_user.followers, :count).by(1) 
        end

        describe "toggling the button" do
          before { click_button 'follow' }
          it { should have_xpath("//input[@value='unfollow']") }
        end
      end

      describe "unfollow a user" do
        before do
          user.follow!(other_user)
          visit user_path(other_user)
        end

        it "should decrement the followed user count" do
          expect do
            click_button('unfollow')
          end.to change(user.followed_users, :count).by(-1)
        end

        it "should decrement the other user's followers count" do
          expect do
            click_button('unfollow').to change(other_user.followers, :count).by(-1)
          end
        end

        describe "toggling the button" do
          before { click_button 'unfollow' }
          it { should have_xpath("//input[@value='follow']") }
        end
      end
    end
  end

  describe "edit" do
    let(:user) { FactoryGirl.create(:user) }
    before do
      sign_in user
      visit edit_user_path(user)
    end

    describe "page" do
      it { should have_content('Update your profile') }
      it { should have_link('change', href: 'http://gravatar.com/emails') }
      it { should have_title('Edit user') }
    end

    describe "with invalid infomation" do
      before { click_button 'Save change' }

      it { should have_content 'error' }
    end

    describe "with valid infomation" do
      let(:new_name) { 'New name' }
      let(:new_email) { 'new@exmaple.com' }

      before do
        fill_in 'Name',             with: new_name
        fill_in 'Email',            with: new_email
        fill_in 'Password',         with: user.password
        fill_in 'Confirm',          with: user.password
        click_button 'Save change'
      end

      it { should have_title('New name') }
      it { should have_selector('div.alert.alert-success') }
      it { should have_link('Sign out', href: signout_path) }
      specify { expect(user.reload.name).to eq new_name }
      specify { expect(user.reload.email).to eq new_email }
    end

    describe "forbidden attributes" do
      let(:params) do
        { user: { admin: true, password: user.password,
                  password_confirmation: user.password } }
      end
      before { patch user_path(user), params }
      specify { expect(user.reload).not_to be_admin }
    end
  end

  describe "following/follower" do
    let(:user) { FactoryGirl.create(:user) }
    let(:other_user) { FactoryGirl.create(:user) }
    before { user.follow!(other_user) }

    describe "followed user" do
      before do
        sign_in user
        visit following_user_path(user)
      end

      it { should have_title(full_title('Following')) }
      it { should have_selector('h3', text: 'Following') }
      it { should have_link(other_user.name, href: user_path(other_user)) }
    end

    describe "followers" do
      before do
        sign_in other_user
        visit followers_user_path(user)
      end

      it { should have_title(full_title('Followers')) }
      it { should have_selector('h3', text: 'Followers') }
      it { should have_link(user.name, href: user_path(user)) }
    end
  end
end
