
def record_pid
  pid =  Process.pid
  pid_file = "#{Rails.root}/tmp/pids/stalker.pid"
  File.open(pid_file,"w") {|f| f.write pid}
end

namespace :stalker do

  desc "starts Stalker, the client for beanstalk, so that jobs are processed in background"
  task :start => :environment do
    record_pid
    job_file = "#{Rails.root}/lib/jobs.rb"
    include Stalker
    require job_file
    Stalker.work
  end
  
end
