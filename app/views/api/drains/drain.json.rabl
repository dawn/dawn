object @drain
attributes :id, :created_at, :updated_at, :url, :token
child(:app) { attribute id: :app_id }
