rails_env = ENV['RAILS_ENV'] || 'development'
rails_root = '/home/eugenio/workspaces/cc'#ENV['RAILS_ROOT'] || File.dirname(__FILE__) + '/..' #To be modified later, will use another env var
#RESQUE POOL

God.watch do |w|
  w.dir      = "#{rails_root}"
  w.name     = "resque-pool"
  w.group    = 'resque'

  w.interval = 30.seconds
  w.env      = { "RAILS_ENV" => rails_env }
  w.start    = "bundle exec resque-pool -d -o #{rails_root}/log/resque-pool.stdout -e #{rails_root}/log/resque-pool.stderr -p #{rails_root}/tmp/pids/resque-pool.pid"

  w.pid_file = "#{rails_root}/tmp/pids/resque-pool.pid"
  w.behavior(:clean_pid_file)

  # determine the state on startup
  w.transition(:init, { true => :up, false => :start }) do |on|
    on.condition(:process_running) do |c|
      c.running = true
    end
  end

  # determine when process has finished starting
  w.transition([:start, :restart], :up) do |on|
    on.condition(:process_running) do |c|
      c.running = true
      c.interval = 5.seconds
    end

    # failsafe
    on.condition(:tries) do |c|
      c.times = 5
      c.transition = :start
      c.interval = 5.seconds
    end
  end

  # start if process is not running
  w.transition(:up, :start) do |on|
    on.condition(:process_running) do |c|
      c.running = false
    end
  end
end


#RESQUE SCHEDULER

God.watch do |w|
  w.dir      = "#{rails_root}"
  w.name     = "resque_scheduler"
  w.interval = 30.seconds
  w.env      = {"RAILS_ENV"=>rails_env}

  w.start    = "bundle exec rake resque:scheduler"
  w.log      = "#{rails_root}/log/resque_scheduler.log"
  w.err_log  = "#{rails_root}/log/resque_scheduler_error.log"

  # determine the state on startup
  w.transition(:init, { true => :up, false => :start }) do |on|
    on.condition(:process_running) do |c|
      c.running = true
    end
  end

  # determine when process has finished starting
  w.transition([:start, :restart], :up) do |on|
    on.condition(:process_running) do |c|
      c.running = true
      c.interval = 5.seconds
    end

    # failsafe
    on.condition(:tries) do |c|
      c.times = 5
      c.transition = :start
      c.interval = 5.seconds
    end
  end

  # start if process is not running
  w.transition(:up, :start) do |on|
    on.condition(:process_running) do |c|
      c.running = false
    end
  end
end