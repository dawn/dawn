object @app
attributes :id, :created_at, :updated_at, :name, :version, :env, :formation
node(:url) { |a| a.url }
