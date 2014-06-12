object @gear
node(:name)   { |gear| gear.name }
node(:uptime) { |gear| gear.uptime }
attributes :id, :created_at, :updated_at, :number, :app_id
attribute :proctype => :type
