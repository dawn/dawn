object @release
attributes :id, :created_at, :updated_at, :image, :version
child(:app) { attribute id: :app_id }
