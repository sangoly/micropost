class User < ActiveRecord::Base

  has_many :microposts, dependent: :destroy
  has_many :relationships, foreign_key: 'follower_id', dependent: :destroy
  has_many :followed_users, through: :relationships, source: :followed
  # The reverse_relationships is a virtual tables, see the 'class_name' hash key
  has_many :reverse_relationships, foreign_key: 'followed_id', class_name: 'Relationship',
                                                               dependent: :destroy
                                                               
  # Or, just 'has_many :followers, through: :reverse_relationships'
  has_many :followers, through: :reverse_relationships, source: :follower

  before_save { email.downcase! }
  before_create :create_remember_token

  validates :name, 
  			presence: true, 
  			length: { maximum: 50 }

  # The regex for email validation
  VALID_EMAIL_REGEX = /\A[\w+\-.]+@[a-z\d\-]+(\.[a-z]+)*\.[a-z]+\z/i
  
  validates :email, 
  			presence: true, 
  			format: { with: VALID_EMAIL_REGEX },
            uniqueness: { case_sensitive: false }

  has_secure_password
  validates :password, length: { minimum: 6 }

  def feed
    Micropost.from_users_followed_by(self)
  end


  # Help methods for follow other user
  def following?(other_user)
    relationships.find_by(followed_id: other_user.id)
  end

  def follow!(other_user)
    relationships.create!(followed_id: other_user.id)
  end

  def unfollow!(other_user)
    relationships.find_by(followed_id: other_user.id).destroy
  end

  # Generate the screte remember token
  def User.new_remember_token
    SecureRandom.urlsafe_base64
  end

  def User.hash(token)
    Digest::SHA1.hexdigest(token.to_s)
  end

  private

    def create_remember_token
      self.remember_token = User.hash(User.new_remember_token)
    end
end
