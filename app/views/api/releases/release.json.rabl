object @release
attributes :id, :created_at, :updated_at, :image
node(:version) { |r| r.version }
child(:app) { attribute id: :app_id }
