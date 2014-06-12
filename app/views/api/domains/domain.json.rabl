object @domain
attributes :id, :created_at, :updated_at, :url
child(:app) { attribute id: :app_id }
