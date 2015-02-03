class Setup < ActiveRecord::Base
  validates :host, presence: true, format: { with: /\A([\s,]*[a-zA-Z0-9\-\[\]\.][\s,]*)+\Z/ }
  validates :user, presence: true, inclusion: { in: ["admin", "dummy", "setup", "root"] }

  before_save :set_auth_method
  after_save :index
  after_destroy :remove_from_index

  searchable do
    text :host
    text :user
    text :ssh_key
    text :password
    text :setup_role
    text :state
    text :dry_run do
      dry_run.to_s
    end

    string :host
    string :user
    string :ssh_key
    string :password
    string :setup_role
    string :state
    boolean :dry_run
    date :created_at
  end

  def index
    index!
  end

  def remove_from_index
    remove_from_index!
  end

  private
  def set_auth_method
    case user
    when "dummy"
      self.password = "dummy" if user == "dummy"
    else
      self.ssh_key = "~/.ssh/id_rsa_#{user}" # local rule
    end
  end
end
