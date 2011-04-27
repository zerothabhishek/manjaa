#!/usr/bin/env ruby

StalkerPIDFile = File.expand_path("../../tmp/pids/stalker.pid", __FILE__)
StalkerLogFile = File.expand_path("../../log/jobs.log", __FILE__)

class StalkerDaemon

  def self.start
    stop      # a start is always a restart
    
    command = "nohup rake stalker:start >> #{StalkerLogFile}  2>&1 &"
    output = `#{command}`    
    raise output unless $?.success?
  end
  
  def self.stop
    return unless stalker_running?
    kill_current_stalker
    File.open(StalkerPIDFile, "w"){|f| f.write nil }
  end  
  
  private
  
  def self.kill_current_stalker
    Process.kill("SIGTERM", current_stalker_pid)    
  end
  
  def self.current_stalker_pid
    return nil unless File.exists? StalkerPIDFile
    File.read(StalkerPIDFile).to_i  
  end
  
  def self.stalker_running?
    begin 
      Process.getpgid(current_stalker_pid)
      true
    rescue Errno::ESRCH
      false
    end
  end
end

arg = ARGV.shift
case arg
when "stop"
  StalkerDaemon.stop
when "start"
  StalkerDaemon.start
else
  StalkerDaemon.start
end