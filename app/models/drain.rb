class Drain < ActiveRecord::Base

  validates :url, presence: true

  before_create :create_logplex_drain
  before_destroy :destroy_logplex_drain

  private def create_logplex_drain
    resp = Logplex.post(
      expects: 201,
      path: "/v2/channels/#{app.logplex_id}/drains",
      body: {url: self.url}.to_json,
      headers: { 'Content-Type' => 'application/x-www-form-urlencoded' }
    )
    resp = JSON.parse(resp.body)

    self.drain_id = resp['id']
    self.token = resp['token']
  end

  private def destroy_logplex_drain
    Logplex.delete(path: "/v2/channels/#{app.logplex_id}/drains/#{drain_id}")
  end

  belongs_to :app

end