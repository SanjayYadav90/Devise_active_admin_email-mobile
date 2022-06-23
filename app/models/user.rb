class User < ApplicationRecord
  # Include default devise modules. Others available are:
  # :confirmable, :lockable, :timeoutable, :trackable and :omniauthable
  devise :database_authenticatable, :registerable,
         :recoverable, :rememberable, :validatable
  attr_writer :login

  def login
    @login || self.mobile || self.email
  end

  validates :mobile, :presence => true, :uniqueness => { :case_sensitive => false }
  # validate :validate_username

  def validate_username
    if User.where(email: mobile).exists?
      errors.add(:mobile, :invalid)
    end
  end

  
  def self.find_first_by_auth_conditions(warden_conditions)
    conditions = warden_conditions.dup
    if (login = conditions.delete(:login))
      where(conditions).where(["lower(mobile) = :value OR lower(email) = :value", { :value => login.downcase }]).first
    else
      if conditions[:mobile].nil?
        where(conditions).first
      else
        where(mobile: conditions[:mobile]).first
      end
    end
  end
end
