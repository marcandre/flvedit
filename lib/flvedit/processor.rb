%w(base filter dispatcher add command_line cut debug head join print reader save update).each do |proc|
  require_relative "processor/#{proc}"
end