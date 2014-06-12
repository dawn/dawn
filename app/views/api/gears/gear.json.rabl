object @gear
attributes :id, :created_at, :updated_at, :number, :proctype
node(:name)   { |gear| gear.name }
node(:uptime) { |gear| gear.uptime }
child(:app) { attribute id: :app_id }
