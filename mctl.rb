#!/usr/bin/env ruby

trap("INT") do 
    pid = spawn("echo /stop > command_input")
    Process.detach(pid)
    puts "Waiting for server #{$server_pid} to stop"
    Process.wait($server_pid)
    exit 0
end

trap("TERM") do 
    STDERR.puts "Caught TERM signal"
    Process.kill("TERM", $server_pid)
    Process.wait($server_pid)
    exit 0
end

trap("USR1") do 
    pid = spawn("echo /save-all > command_input")
    Process.detach(pid)
	STDERR.puts "Acted on USR1 signal"
end

puts "mctl started with PID #{$$}"

# Fork a process so as to keep the FIFO open and prevent blocking Java
Process.fork do
	File.open("command_input", "w")
	sleep
end

# Now we can spawn the server process without holding anything up
$server_pid = spawn("/Library/Internet Plug-Ins/JavaAppletPlugin.plugin/Contents/Home/bin/java", "-Xmx1024M", "-Xms1024M", "-jar", "server.jar", "nogui", :in=>"command_input", [:out, :err]=>"/dev/null")
puts "server started with PID #{$server_pid}"

# And now we wait for signals
puts "mctl sleeping"
STDOUT.flush
sleep
