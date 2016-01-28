class User < ActiveRecord::Base
  enum role: [:user, :vip, :admin, :driver, :accountant]
  after_initialize :set_default_role, :if => :new_record?
  before_save :ensure_authentication_token

  has_many :route_plans

  def name
    "#{self.first_name} #{self.last_name}"
  end

  def set_default_role
    self.role = :user
  end

  def set_admin_role
    self.role = :admin
  end

  def set_driver_role
    self.role = :driver
  end

  def ensure_authentication_token
    if authentication_token.blank?
      self.authentication_token = generate_authentication_token
    end
  end

  private

    def generate_authentication_token
      loop do
        token = Devise.friendly_token
        break token unless User.where(authentication_token: token).first
      end
    end

  # Include default devise modules. Others available are:
  # :confirmable, :lockable, :timeoutable and :omniauthable
  devise :database_authenticatable, :registerable,
         :recoverable, :rememberable, :trackable, :validatable
end