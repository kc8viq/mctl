#!/usr/bin/env ruby

trap("INT") do 
    puts "SIGINT received. Use SIGTERM instead.\n"
end

trap("TERM") do 
    pid = spawn("echo /stop > command_input")
    Process.detach(pid)
    puts "Waiting for server #{$server_pid} to stop"
    Process.wait($server_pid)
    exit 0
end

trap("USR1") do 
    pid = spawn("echo /save-all > command_input")
    Process.detach(pid)
	puts "Sent /save-all command"
end

puts "mctl started with PID #{$$}"
unless File.exists?('command_input')
	puts "command fifo missing"
	spawn("mkfifo", "command_input")
	Process.wait
	puts "created command fifo"
end

# Use a thread to keep the FIFO open and prevent blocking stdin for Java process
thr = Thread.new do
	File.open("command_input", "w")
	sleep
end

# Now we can spawn the server process without holding anything up
# $server_pid = spawn("java", "-Xmx1024M", "-Xms512M", "-jar", "server.jar", "nogui", :in=>"command_input", [:out, :err]=>"/dev/null")
$server_pid = spawn("java -Xmx1024M -Xms512M -jar server.jar nogui < command_input")
puts "server started with PID #{$server_pid}"

# And now we wait for signals
puts "mctl sleeping"
STDOUT.flush
sleep
