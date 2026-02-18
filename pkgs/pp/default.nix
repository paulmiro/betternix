{
  writers,
  zellij,
  ...
}:
writers.writeRubyBin "pp" { } ''
  require 'erb'
  require 'tempfile'

  if ARGV.length < 3
      puts "Usage: pp <environment> <server_type> <numbers...>"
      puts "Example: pp test web 1 2"
      exit 1
  end

  environment, server_type, *numbers = ARGV

  if environment == "dev"
      names = numbers.map { |n| "betterdev-#{server_type}-#{n}" }
  if environment == "test"
      names = numbers.map { |n| "bettertest-#{server_type}-#{n}" }
  elsif environment == "prod"
      names = numbers.map { |n| "bettertec-#{server_type}-#{n}" }
  else
      puts "Unknown environment: #{environment}"
      exit 1
  end

  if ["db", "monitor", "sftp", "web", "worker", "net", "work"].include?(server_type) == false
      puts "Unknown server type: #{server_type}"
      exit 1
  end

  numbers.each do |n|
      if n.to_i.to_s != n
          puts "Not an integer: #{n}"
          exit 1
      end
  end

  names.each do |name|
      `ping -c 1 -W 5 #{name}`
      if $?.exitstatus != 0
          puts "Could not ping #{name}, is your VPN connected?"
          exit 1
      end
      `ssh #{name} 'true'`
      if $?.exitstatus != 0
          puts "Could not ssh to #{name}, is your ssh config correct?"
          exit 1
      end
  end


  layout_template = File.read("${./layout.erb}")
  pane_template = File.read("${./pane.erb}")

  panes = ""
  names.each do |name|
      panes += ERB.new(pane_template).result(binding)
  end

  layout = ERB.new(layout_template).result(binding)

  layout_file = Tempfile.new("pp-layout.kdl")
  layout_file.write(layout)
  layout_file.close

  exec("${zellij}/bin/zellij -l #{layout_file.path}")
''
