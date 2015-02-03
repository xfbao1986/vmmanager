class User < ActiveRecord::Base
  # Include default devise modules. Others available are:
  # :token_authenticatable, :confirmable,
  # :lockable, :timeoutable and :omniauthable 
  # :recoverable,:rememberable,registerable
  devise :database_authenticatable, :validatable,:trackable, :omniauthable
  
  def self.generate_random_password
    # avoid storing ldap password to app DB.
    Digest::SHA1.hexdigest(Time.now.to_s)
  end

  searchable do
    text :name
    text :email
    text :admin do
      admin.to_s
    end
    string :name
    string :email
    boolean :admin
  end

  after_save :index
  after_destroy :remove_from_index

  def index
    index!
  end

  def remove_from_index
    remove_from_index!
  end
end
