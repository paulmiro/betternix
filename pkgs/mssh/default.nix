{
  writers,
  zellij,
  ...
}:
writers.writeRubyBin "mssh" { } ''
  require 'erb'
  require 'tempfile'

  def usage
      puts
      puts "Multi-SSH: run a command on multiple servers at once"
      puts
      puts "Usage: mssh <environment> <server_type> <numbers...> -- <command>"
      puts "Example: mssh test web 1 2 -- tail -f /var/log/nginx/access.log"
      exit 1
  end

  if ARGV.length == 0
      usage
  end

  if ARGV.length < 3
      puts "Error: Not enough arguments"
      usage
  end 

  environment = ARGV.shift
  server_type = ARGV.shift

  numbers = []
  command = ""
  ARGV.each do |arg|
      if arg == "--"
          command = ARGV.drop(ARGV.index("--") + 1).join(" ")
          break
      end
      numbers << arg
  end

  if environment == "dev"
      names = numbers.map { |n| "betterdev-#{server_type}-#{n}" }
  elsif environment == "test"
      names = numbers.map { |n| "bettertest-#{server_type}-#{n}" }
  elsif environment == "ncetest"
      names = numbers.map { |n| "ncetest-#{server_type}-#{n}" }
  elsif environment == "prod"
      names = numbers.map { |n| "bettertec-#{server_type}-#{n}" }
  elsif environment == "nceprod"
      names = numbers.map { |n| "nce-#{server_type}-#{n}" }
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

  layout_file = Tempfile.new(%w/mssh-layout .kdl/)
  layout_file.write(layout)
  layout_file.close

  exec("${zellij}/bin/zellij -l #{layout_file.path}")
''
