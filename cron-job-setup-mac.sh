# wakeup on Wednesdays at 2:15 AM
sudo pmset repeat wakeorpoweron We 02:15:00

# Verify:
sudo pmset -g sched

# Enable "Wake for network access" (Wake-on-LAN), run once, cancel it by changing 1 to 0
sudo pmset -a womp 1

# Then
sudo env EDITOR=nano crontab -e
# Add the cron job for Wednesdays at 2:15 AM
15 2 * * 3 caffeinate -di -t 21600



# Alternative
# Create the plist file
nano ~/Library/LaunchAgents/com.user.caffeinate.plist
# Copy this:
<?xml version="1.0" encoding="UTF-8"?>
<!DOCTYPE plist PUBLIC "-//Apple//DTD PLIST 1.0//EN" "http://www.apple.com/DTDs/PropertyList-1.0.dtd">
<plist version="1.0">
<dict>
    <key>Label</key>
    <string>com.user.caffeinate</string>
    <key>ProgramArguments</key>
    <array>
        <string>caffeinate</string>
        <string>-di</string>
        <string>-t</string>
        <string>21600</string>
    </array>
    <key>StartCalendarInterval</key>
    <dict>
        <key>Weekday</key>
        <integer>3</integer>
        <key>Hour</key>
        <integer>2</integer>
        <key>Minute</key>
        <integer>15</integer>
    </dict>
</dict>
</plist>

# load it
launchctl load ~/Library/LaunchAgents/com.user.caffeinate.plist