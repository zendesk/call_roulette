require File.expand_path(File.join(File.dirname(__FILE__), '..', '..', 'config', 'boot'))
require File.expand_path(File.join(File.dirname(__FILE__), '..', '..', 'config', 'environment'))

include Clockwork

handler do |job|
  Call.connect_random_strangers
end

every(1.seconds, 'router.connect')
