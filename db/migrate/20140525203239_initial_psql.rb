class InitialPsql < ActiveRecord::Migration

  def change
    enable_extension 'hstore'

    create_table :apps do |t|
      t.timestamps

      t.string  :name
      t.hstore  :env,       default: {}
      t.string  :git        # path to the git repository
      t.hstore  :formation, default: {web: 1} # how many gears of what type do we have
      t.integer :version,   default: 0 # release version tracker

      t.integer :logplex_id
      t.hstore  :logplex_tokens, default: {}

      t.belongs_to :user
    end

    create_table :gears do |t|
      t.timestamps

      # type ? needs a different name because of the way fields stored polymorphic + is a symbol
      t.integer :number
      t.integer :port
      t.string  :ip
      t.string  :container_id # pid/identifier of the Docker container
      t.time    :started_at # default val Time.now

      t.belongs_to :app
    end

    create_table :releases do |t|
      t.timestamps

      t.string  :image # the docker image name (typically <user>/<app>:v<number>)
      t.integer :version

      t.belongs_to :app
    end

    create_table :drains do |t|
      t.timestamps

      t.string  :url
      t.integer :drain_id
      t.string  :token

      t.belongs_to :app
    end

    create_table :keys do |t|
      t.timestamps

      t.string :key
      t.string :fingerprint

      t.belongs_to :user
    end

    create_table :users do |t|
      t.timestamps

      t.string :username

      ## Database authenticatable
      t.string :email,  default: ""
      t.string :encrypted_password,  default: ""

      ## Recoverable
      t.string :reset_password_token
      t.time   :reset_password_sent_at

      ## Rememberable
      t.time :remember_created_at

      ## Trackable
      t.integer :sign_in_count, default: 0
      t.time    :current_sign_in_at
      t.time    :last_sign_in_at
      t.string  :current_sign_in_ip
      t.string  :last_sign_in_ip

      ## Confirmable
      # t.string :confirmation_token
      # t.time :confirmed_at
      # t.time :confirmation_sent_at
      # t.string :unconfirmed_email # Only if using reconfirmable

      ## Lockable
      # t.integer :failed_attempts, default: 0 # Only if lock strategy is :failed_attempts
      # t.string :unlock_token # Only if unlock strategy is :email or :both
      # t.time :locked_at

      t.string :api_key # TODO: defaults to proc...

      t.belongs_to :user
    end

    add_index :users, :email,                unique: true
    add_index :users, :reset_password_token, unique: true
    # add_index :users, :confirmation_token,   unique: true
    # add_index :users, :unlock_token,         unique: true
  end

end