require 'spec_helper'

describe User do
  #pending "add some examples to (or delete) #{__FILE__}"
  before { @user = User.new(name: "Example Name",
  	                        email: "Example@mail.cn",
                            password: "foobar",
                            password_confirmation: "foobar") }
  subject { @user }
  it { should respond_to(:name) }
  it { should respond_to(:email) }
  it { should respond_to(:password_digest) }
  it { should respond_to(:password) }
  it { should respond_to(:password_confirmation) }
  it { should respond_to(:authenticate) }
  it { should respond_to(:remember_token) }
  it { should be_valid }

  describe "when name is not present" do
  	before { @user.name = "" }
  	it { should_not be_valid }
  end

  describe "when email is not present" do
  	before { @user.email = "" }
  	it { should_not be_valid }
  end

  describe "when name is to long" do
  	before { @user.name = "a" * 51 }
  	it { should_not be_valid }
  end

  describe "when email format is invalid" do
    it "should be invalid" do
      addresses = %w[user@foo,com user_at_foo.org example.user@foo.
                     foo@bar_baz.com foo@bar+baz.com]
      addresses.each do |invalid_address|
        @user.email = invalid_address
        expect(@user).not_to be_valid
      end
    end
  end

  describe "when email format is valid" do
    it "should be valid" do
      addresses = %w[user@foo.COM A_US-ER@f.b.org frst.lst@foo.jp a+b@baz.cn]
      addresses.each do |valid_address|
        @user.email = valid_address
        expect(@user).to be_valid
      end
    end
  end

  describe "when email address is already taken" do
  	before do
	  user_with_same_email = @user.dup
	  user_with_same_email.email = @user.email.upcase
	  user_with_same_email.save
  	end
  	it { should_not be_valid }
  end

  describe "when password is not exist" do
    before do
      @user = User.new(name: "Example User", email: "user@example.com",
                     password: " ", password_confirmation: " ")
    end
    it { should_not be_valid }
  end

  describe "when password is not match confirmation" do
    before { @user.password_confirmation = "dismatch" }
    it { should_not be_valid }    
  end

  describe "with password this is too short" do
    before { @user.password = @user.password_confirmation = 'a' * 5 }
    it { should be_invalid }
  end

  describe "return value of invalid authenticate" do
    before { @user.save }
    let(:founder_user) { User.find_by(email: @user.email) }

    describe "with valid password" do
      it { should eq founder_user.authenticate(@user.password) }
    end

    describe "with invalid password" do
      let(:user_with_invalid_password) { founder_user.authenticate("invalid") }
      it { should_not eq user_with_invalid_password}
      #specify is alais of it
      specify { expect(user_with_invalid_password).to be_false }
    end
  end

  describe "email address with mixed case" do
    let(:email_with_mixed_case) { "UsEr@ExAMPle.Com" }
    it "should be valid" do
      @user.email = email_with_mixed_case
      @user.save
      expect(@user.reload.email).to eq email_with_mixed_case.downcase
    end
  end

  describe "remember token" do
    before { @user.save }
    its(:remember_token) { should_not be_blank }
  end
end
