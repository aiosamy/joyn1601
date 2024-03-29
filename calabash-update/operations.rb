require 'json'
require 'net/http'
require 'open-uri'
require 'rubygems'
require 'json'
require 'socket'
require 'timeout'
require 'calabash-android/helpers'
require 'retriable'


module Calabash module Android

module Operations


  def log(message)
    $stdout.puts "#{Time.now.strftime("%Y-%m-%d %H:%M:%S")} - #{message}" if (ARGV.include? "-v" or ARGV.include? "--verbose")
  end

  def take_screenshot
    default_device.take_screenshot
  end

  def macro(txt)
    if self.respond_to?(:step)
      step(txt)
    else
      Then(txt)
    end
  end



  def default_device

case $device
when 1
unless @default_device1 
      @default_device1 = Device.new(self, ENV["ADB_DEVICE_ARG"], ENV["TEST_SERVER_PORT"], ENV["APP_PATH"], ENV["TEST_APP_PATH"])
@default_device=@default_device1    
end
@default_device=@default_device1

when 2

unless @default_device2 
      @default_device2 = Device.new(self, ENV["ADB_DEVICE_ARG2"], ENV["TEST_SERVER_PORT2"], ENV["APP_PATH"], ENV["TEST_APP_PATH"])
@default_device=@default_device2    
end
@default_device=@default_device2

else
unless @default_device
      @default_device = Device.new(self, ENV["ADB_DEVICE_ARG"], ENV["TEST_SERVER_PORT"], ENV["APP_PATH"], ENV["TEST_APP_PATH"])
end
@default_device
end
end




  def performAction(action, *arguments)
    default_device.perform_action(action, *arguments)
  end

  def install_app(app_path)
    default_device.install_app(app_path)
  end

  def uninstall_apps
    default_device.uninstall_app("sh.calaba.android.test")
    #default_device.uninstall_app(ENV["PACKAGE_NAME"])
  end

  def wake_up
    default_device.wake_up()
  end

  def clear_app_data
    default_device.clear_app_data
  end

  def start_test_server_in_background(options={})
    default_device.start_test_server_in_background()
  end

  def shutdown_test_server
    default_device.shutdown_test_server
  end

  def screenshot_embed(options={:prefix => nil, :name => nil, :label => nil})
    path = default_device.screenshot(options)
    embed(path, "image/png", options[:label] || File.basename(path))
  end

  def screenshot(options={:prefix => nil, :name => nil})
    default_device.screenshot(options)
  end

  def set_gps_coordinates_from_location(location)
    default_device.set_gps_coordinates_from_location(location)
  end

  def set_gps_coordinates(latitude, longitude)
    default_device.set_gps_coordinates(latitude, longitude)
  end

  def wait_for(timeout, &block)
    value = nil
    begin
      Timeout::timeout(timeout) do
        until (value = block.call)
          sleep 0.3
        end
      end
    rescue Exception => e
      raise e
    end
    value
  end

  def query(uiquery, *args)
    if uiquery.start_with? "webView"
      uiquery.slice!(0, "webView".length)
      if uiquery =~ /(css|xpath):\s*(.*)/
        r = performAction("query", $1, $2)
        JSON.parse(r["message"])
      else
       raise "Invalid query #{uiquery}"
      end
    else
      arguments = [*args]
      operation = {"method_name"=>"query", "arguments" => arguments}
      data = {"query" => uiquery, "operation" => operation}
      JSON.parse(http("/map",data))
    end
  end

  def ni
    raise "Not yet implemented."
  end

  ###

  ### app life cycle
  def connect_to_test_server
    puts "Explicit calls to connect_to_test_server should be removed."
    puts "Please take a look in your hooks file for calls to this methods."
    puts "(Hooks are stored in features/support)"
  end

  def disconnect_from_test_server
    puts "Explicit calls to disconnect_from_test_server should be removed."
    puts "Please take a look in your hooks file for calls to this methods."
    puts "(Hooks are stored in features/support)"
  end

  class Device

    def make_default_device
      @cucumber_world.default_device = self
    end

    def initialize(cucumber_world, serial, server_port, app_path, test_server_path)
      @cucumber_world = cucumber_world
      @serial = serial
      @server_port = server_port
      @app_path = app_path
      @test_server_path = test_server_path

      forward_cmd = "#{adb_command} forward tcp:#{server_port} tcp:7102"
      log forward_cmd
      log `#{forward_cmd}`
    end

    def reinstall_apps()
      uninstall_app(package_name(@app_path))
      install_app(@app_path)
      uninstall_app(package_name(@test_server_path))
      install_app(@test_server_path)
    end

    def install_app(app_path)
      cmd = "#{adb_command} install \"#{app_path}\""
      log "Installing: #{app_path}"
      result = `#{cmd}`
      log result
      pn = package_name(app_path)
      succeeded = `#{adb_command} shell pm list packages`.include?("package:#{pn}")

      unless succeeded
        Cucumber.wants_to_quit = true
        raise "#{pn} did not get installed. Aborting!"
      end
    end

    def uninstall_app(package_name)
      log "Uninstalling: #{package_name}"
      log `#{adb_command} uninstall #{package_name}`
    end

    def app_running?
      `#{adb_command} shell ps`.include?(ENV["PROCESS_NAME"] || package_name(@app_path))
    end

    def keyguard_enabled?
      dumpsys = `#{adb_command} shell dumpsys window windows`
      #If a line containing mCurrentFocus and Keyguard exists the keyguard is enabled
      dumpsys.lines.any? { |l| l.include?("mCurrentFocus") and l.include?("Keyguard")}
    end

    def perform_action(action, *arguments)
      log "Action: #{action} - Params: #{arguments.join(', ')}"

      params = {"command" => action, "arguments" => arguments}

      Timeout.timeout(300) do
        begin
          result = http("/", params, {:read_timeout => 350})
        rescue Exception => e
          log "Error communicating with test server: #{e}"
          raise e
        end
        log "Result:'" + result.strip + "'"
        raise "Empty result from TestServer" if result.chomp.empty?
        result = JSON.parse(result)
        if not result["success"] then
          raise "Step unsuccessful: #{result["message"]}"
        end
        result
      end
    rescue Timeout::Error
      raise Exception, "Step timed out"
    end

    def http(path, data = {}, options = {})
      begin
        http = Net::HTTP.new "127.0.0.1", @server_port
        http.open_timeout = options[:open_timeout] if options[:open_timeout]
        http.read_timeout = options[:read_timeout] if options[:read_timeout]
        resp = http.post(path, "#{data.to_json}", {"Content-Type" => "application/json;charset=utf-8"})
        resp.body
      rescue Exception => e
        if app_running?
          raise e
        else
          raise "App no longer running"
        end
      end
    end

    def take_screenshot
      puts "take_screenshot is deprecated. Use screenshot_embed instead."
      path = ENV["SCREENSHOT_PATH_PREFIX"] || "results"
      FileUtils.mkdir_p path unless File.exist? path
      filename_prefix = FeatureNameMemory.feature_name.gsub(/\s+/, '_').downcase
      begin
        Timeout.timeout(30) do
          file_name = "#{path}/#{filename_prefix}_#{FeatureNameMemory.invocation}_#{StepCounter.step_line}.png"
          image = http("/screenshot")
          open(file_name ,"wb") { |file|
            file.write(image)
          }
          log "Screenshot stored in: #{file_name}!!!"
        end
      rescue Timeout::Error
        raise Exception, "take_screenshot timed out"
      end
    end

    def screenshot(options={:prefix => nil, :name => nil})
      prefix = options[:prefix] || ENV['SCREENSHOT_PATH'] || ""
      name = options[:name]

      if name.nil?
        name = "screenshot"
      else
        if File.extname(name).downcase == ".png"
          name = name.split(".png")[0]
        end
      end

      @@screenshot_count ||= 0



if $device==2
path = "Device2_#{prefix}#{name}_#{@@screenshot_count}.png"
else

if $device==1
path = "Device1_#{prefix}#{name}_#{@@screenshot_count}.png"
else      
path= "#{prefix}#{name}_#{@@screenshot_count}.png"
end
end
      if ENV["SCREENSHOT_VIA_USB"] == "true"
        device_args = "-s #{@serial}" if @serial
        screenshot_cmd = "java -jar #{File.join(File.dirname(__FILE__), 'lib', 'screenShotTaker.jar')} #{path} #{device_args}"
        log screenshot_cmd
        raise "Could not take screenshot" unless system(screenshot_cmd)
      else
        begin
          res = http("/screenshot")
        rescue EOFError
          raise "Could not take screenshot. App is most likely not running anymore."
        end
        File.open(path, 'wb') do |f|
          f.write res
        end
      end


      @@screenshot_count += 1
      path
    end

    def adb_command
  if is_windows?
        %Q("#{ENV["ANDROID_HOME"]}\\platform-tools\\adb.exe" #{device_args})
      else
        %Q("#{ENV["ANDROID_HOME"]}/platform-tools/adb" #{device_args})
      end
    end

    def device_args
      if @serial
        "-s #{@serial}"
      else
        ""
      end
    end

    def wake_up
      wake_up_cmd = "#{adb_command} shell am start -a android.intent.action.MAIN -n sh.calaba.android.test/sh.calaba.instrumentationbackend.WakeUp"
      log "Waking up device using:"
      log wake_up_cmd
      raise "Could not wake up the device" unless system(wake_up_cmd)

      retriable :tries => 10, :interval => 1 do
        raise "Could not remove the keyguard" if keyguard_enabled?
      end
    end

    def clear_app_data
      cmd = "#{adb_command} shell am instrument sh.calaba.android.test/sh.calaba.instrumentationbackend.ClearAppData"
      raise "Could not clear data" unless system(cmd)
    end

    def start_test_server_in_background(options={})
      raise "Will not start test server because of previous failures." if Cucumber.wants_to_quit

      if keyguard_enabled?
        wake_up
      end

      env_options = {:target_package => options[:target_package] || ENV["PACKAGE_NAME"],
                     :main_activity => options[:main_activity] || ENV["MAIN_ACTIVITY"],
                     :debug => options[:debug] || false,
                     :class => options[:class] || "sh.calaba.instrumentationbackend.InstrumentationBackend"}

      cmd_arr = [adb_command, "shell am instrument"]

      env_options.each_pair do |key, val|
        cmd_arr << "-e"
        cmd_arr << key.to_s
        cmd_arr << val.to_s
      end

      cmd_arr << "sh.calaba.android.test/sh.calaba.instrumentationbackend.CalabashInstrumentationTestRunner"

      cmd = cmd_arr.join(" ")

      log "Starting test server using:"
      log cmd
      raise "Could not execute command to start test server" unless system("#{cmd} 2>&1")

      retriable :tries => 10, :interval => 1 do
        raise "App did not start" unless app_running?
      end

      begin
        retriable :tries => 10, :interval => 3 do
            log "Checking if instrumentation backend is ready"

            log "Is app running? #{app_running?}"
            ready = http("/ready", {}, {:read_timeout => 1})
            if ready != "true"
              log "Instrumentation backend not yet ready"
              raise "Not ready"
            else
              log "Instrumentation backend is ready!"
            end
        end

      rescue
        msg = "Unable to make connection to Calabash Test Server at http://127.0.0.1:#{@server_port}/\n"
        msg << "Please check the logcat output for more info about what happened\n"
        raise msg
      end
    end

    def shutdown_test_server
      begin
        http("/kill")
      rescue EOFError
        log ("Could not kill app. App is most likely not running anymore.")
      end
    end

    ##location
    def set_gps_coordinates_from_location(location)
      require 'geocoder'
      results = Geocoder.search(location)
      raise Exception, "Got no results for #{location}" if results.empty?

      best_result = results.first
      set_gps_coordinates(best_result.latitude, best_result.longitude)
    end

    def set_gps_coordinates(latitude, longitude)
      perform_action('set_gps_coordinates', latitude, longitude)
    end
  end



  def label(uiquery)
    ni
  end

  def screenshot_and_raise(msg)
    screenshot_embed
    sleep 5
    raise(msg)
  end

  def touch(uiquery,*args)
    if uiquery.instance_of? String
      elements = query(uiquery, *args)
      raise "No elements found" if elements.empty?
      element = elements.first
    else
      element = uiquery
    end


    center_x = element["frame"]["x"] + element["frame"]["width"] / 2
    center_y = element["frame"]["y"] + element["frame"]["height"] / 2
    performAction("touch_coordinate", center_x, center_y)
  end

  def http(options, data=nil)
    default_device.http(options, data)
  end

  def html(q)
    query(q).map {|e| e['html']}
  end

  def set_text(uiquery, txt)
    raise "Currently queries are only supported for webviews" unless uiquery.start_with? "webView"

    uiquery.slice!(0, "webView".length)
    if uiquery =~ /(css|xpath):\s*(.*)/
      r = performAction("set_text", $1, $2, txt)
      JSON.parse(r["message"])
    else
     raise "Invalid query #{uiquery}"
    end
  end


  def swipe(dir,options={})
      ni
  end

  def cell_swipe(options={})
    ni
  end

  def done
    ni
  end

  def scroll(uiquery,direction)
    ni
  end

  def scroll_to_row(uiquery,number)
    ni
  end

  def pinch(in_out,options={})
    ni
  end

  def rotate(dir)
    ni
  end

  def app_to_background(secs)
    ni
  end

  def element_does_not_exist(uiquery)
    query(uiquery).empty?
  end

  def element_exists(uiquery)
    not element_does_not_exist(uiquery)
  end

  def view_with_mark_exists(expected_mark)
    element_exists( "android.view.View marked:'#{expected_mark}'" )
  end

  def check_element_exists( query )
    if not element_exists( query )
      screenshot_and_raise "No element found for query: #{query}"
    end
  end

  def check_element_does_not_exist( query )
    if element_exists( query )
      screenshot_and_raise "Expected no elements to match query: #{query}"
    end
  end

  def check_view_with_mark_exists(expected_mark)
    check_element_exists( "view marked:'#{expected_mark}'" )
  end

  # a better name would be element_exists_and_is_not_hidden
  def element_is_not_hidden(uiquery)
     ni
  end


  def load_playback_data(recording,options={})
    ni
  end

  def playback(recording, options={})
    ni
  end

  def interpolate(recording, options={})
    ni
  end

  def record_begin
    ni
  end

  def record_end(file_name)
    ni
  end

  def backdoor(sel, arg)
    ni
  end

  def map( query, method_name, *method_args )
    ni
  end

  def url_for( verb )
    ni
  end

  def make_http_request( url, req )
    ni
  end

end


end end
