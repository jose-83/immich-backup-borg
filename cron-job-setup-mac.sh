# wakeup on Wednesdays at 2:15 AM
sudo pmset repeat wakeorpoweron We 02:14:00

# Verify:
sudo pmset -g sched

# Enable "Wake for network access" (Wake-on-LAN), run once, cancel it by changing 1 to 0
sudo pmset -a womp 1


nano ~/Library/LaunchAgents/com.hossein.caffeinate.wed.plist
# add this
<?xml version="1.0" encoding="UTF-8"?>
<!DOCTYPE plist PUBLIC "-//Apple//DTD PLIST 1.0//EN" "http://www.apple.com/DTDs/PropertyList-1.0.dtd">
<plist version="1.0">
  <dict>
    <key>Label</key>
    <string>com.hossein.caffeinate.wed</string>

    <key>ProgramArguments</key>
    <array>
      <string>/usr/bin/caffeinate</string>
      <!-- keep system & display awake for 6h = 21600s -->
      <string>-di</string>
      <string>-t</string>
      <string>21600</string>
    </array>

    <!-- Run at 02:15 on Wednesdays (Weekday=3; Sunday is 0 or 7) -->
    <key>StartCalendarInterval</key>
    <dict>
      <key>Weekday</key><integer>3</integer>
      <key>Hour</key><integer>2</integer>
      <key>Minute</key><integer>15</integer>
    </dict>

    <!-- Optional logs -->
    <key>StandardOutPath</key><string>/Users/hossein/Library/Logs/caffeinate-wed.out.log</string>
    <key>StandardErrorPath</key><string>/Users/hossein/Library/Logs/caffeinate-wed.err.log</string>
  </dict>
</plist>

launchctl bootout gui/$(id -u) ~/Library/LaunchAgents/com.hossein.caffeinate.wed.plist 2>/dev/null || true
launchctl bootstrap gui/$(id -u) ~/Library/LaunchAgents/com.hossein.caffeinate.wed.plist
launchctl enable gui/$(id -u)/com.hossein.caffeinate.wed