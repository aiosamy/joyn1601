require 'calabash-android/management/adb'
require 'calabash-android/operations'
include Calabash::Android::Operations

Before do |scenario|
      $startTime = Time.now.to_f
  start_test_server_in_background

end

After do |scenario|
  if scenario.failed?
$device=1
    screenshot_embed
$device=2
    screenshot_embed
  end
  $device=1
  shutdown_test_server
  $device=2
  shutdown_test_server
end
