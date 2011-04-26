namespace :stalker do

  desc "starts Stalker, the client for beanstalk, so that jobs are processed in background"
  task :start => :environment do
    # nohup starts the process as child of PID-1, not the terminal, so the process lives after we logout (daemon)
    # stalk is the comand
    # Loggin is done to log/jobs.log, both standard output and errror (2>&1)
    # Process is run in background (&)
    command = "nohup stalk #{Rails.root}/lib/jobs.rb >> #{Rails.root}/log/jobs.log 2>&1 &"
    output = `#{command}`
    print "#{output}"
  end

end
