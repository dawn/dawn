object @gear
node(:name)   { |gear| gear.name }
node(:uptime) { |gear| gear.uptime }
attributes :id, :number
attribute :proctype => :type