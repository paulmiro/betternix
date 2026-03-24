{
  writers,
  zellij,
  ...
}:
writers.writeRubyBin "pp" { } ''
  require 'erb'
  require 'tempfile'

  def usage
      puts
      puts "pp: execute puppet on multiple servers at once"
      puts
      puts "Usage: pp <environment> <server_type> <numbers...>"
      puts "Example: pp test web 1 2"
      exit 1
  end

  if ARGV.length == 0
      usage
  end

  if ARGV.length < 3
      puts "Error: Not enough arguments"
      usage
  end

  environment, server_type, *numbers = ARGV

  if environment == "dev"
      names = numbers.map { |n| "betterdev-#{server_type}-#{n}" }
  elsif environment == "test"
      names = numbers.map { |n| "bettertest-#{server_type}-#{n}" }
  elsif environment == "prod"
      names = numbers.map { |n| "bettertec-#{server_type}-#{n}" }
  else
      puts "Error: Unknown environment: #{environment}"
      usage
  end

  if ["db", "monitor", "sftp", "web", "worker", "net", "work"].include?(server_type) == false
      puts "Error: Unknown server type: #{server_type}"
      usage
  end

  numbers.each do |n|
      if n.to_i.to_s != n
          puts "Error: Not an integer: #{n}"
          usage
      end
  end

  names.each do |name|
      `ping -c 1 -W 5 #{name}`
      if $?.exitstatus != 0
          puts "Error: Could not ping #{name}, is your VPN connected?"
          exit 1
      end
      `ssh #{name} 'true'`
      if $?.exitstatus != 0
          puts "Error: Could not ssh to #{name}, is your ssh config correct?"
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
