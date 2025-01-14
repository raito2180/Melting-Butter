class User < ApplicationRecord
  # Include default devise modules. Others available are:
  # :confirmable, :lockable, :timeoutable, :trackable and :omniauthable
  devise :database_authenticatable, :registerable,
         :recoverable, :rememberable, :validatable,
         :omniauthable, omniauth_providers: %i[google_oauth2]

  after_create :create_profile
  has_one :profile, dependent: :destroy
  has_many :contacts, dependent: :destroy
  has_many :responses, dependent: :destroy
  validates :email, uniqueness: true
  def self.from_omniauth(auth)
    where(provider: auth.provider, uid: auth.uid).first_or_create do |user|
      user.email = auth.info.email
      user.password = Devise.friendly_token[0, 20]
    end
  end

  def can_call_api?
    request_limit_count < 3
  end

  private

  def create_profile
    Profile.create(user: self, name: "ファン#{id}号", gender: 0, body: 'こんにちは、皆でフットサルやりましょう!')
  end
end
