object @gear
node(:name)   { |gear| gear.name }
node(:uptime) { |gear| gear.uptime }
attributes :id, :type, :number