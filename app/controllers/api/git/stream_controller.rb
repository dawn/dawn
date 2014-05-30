require 'fileutils'

class ActionController::Live::Buffer
  def flush
    # patch fix for
    # NoMethodError (undefined method `flush' for #<ActionController::Live::Buffer:0x00000003cfea60>):
    # /home/dawn/dashboard/app/models/app.rb:27:in `popen'
  end
end

# Controller for methods needing a stream

class Api::Git::StreamController < ActionController::Base#ApiController

  include ActionController::Live

  def hook
    response.headers['Content-Type'] = 'text/stream'
    real_stdout, $stdout = $stdout, response.stream

    app = App.find_by(git: params[:git])
    app.build
    $stdout.write "\e[1G\n"
    $stdout.write "\e[1G-----> Launching... " # no newline
    app.deploy!
    $stdout.write "done, v#{app.releases.last.version}\n"
    puts "\e[1G       http://#{app.url} deployed to Dawn.io" #.dawn.io
  rescue IOError
  ensure
    response.stream.close
    $stdout = real_stdout
  end

end