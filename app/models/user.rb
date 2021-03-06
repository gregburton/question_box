require 'securerandom'

class User < ActiveRecord::Base
  
  has_many :questions
  has_many :answers

  has_many :comments
  has_many :votes

  validates :email,
            presence: true,
            uniqueness: { case_sensitive: false },
            format: { with: /\A[\w\-\.]+@[\w\-\.]+\Z/, message: "must be a valid email address" }

  validates :name, presence: true

  # This RegEx would allow phone number to be added in the format xxx-xxx-xxxx. Rebecca said that seemed to work for texting initially, but later would only work with format xxxxxxxxxx. So this is commented out and placeholder text in signup form has been adjusted accordingly.

  # validates :phone,
  #           format: { with: /\A(\+\d{1,2}\s)?\(?\d{3}\)?[\s.-]\d{3}[\s.-]\d{4}\z/, unless: "phone.nil?", message: "if you have a phone # it must be valid"}

  validates :score,
            presence: true,
            numericality: { only_integer: true, greater_than_or_equal_to: 0 }
            
  # validates :token, presence: true
  

  has_secure_password
  
  before_validation :set_token

  def to_s
    name
  end
 
  # def send_confirmation
 #    self.update_column(:click, true)
 #    UserMailer.registration_confirmation(@user).deliver
 #  end
  
  def set_token
   self.token = securerandom.urlsafe_base64
  end
  
  def activate_account
    self.update_attribute(:click, true)
    self.update_attribute(:token, nil)
  end
end
