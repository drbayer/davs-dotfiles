#!/usr/bin/env ruby

require 'socket'

hostname = Socket.gethostname()

if hostname.include?('linkedin') or hostname.include?('MacBook-Pro')
    current_env = 'work'
else
    current_env = 'home'
end
#current_env = hostname.include?('linkedin') ? 'work' : 'home'

apps = [
    { app: 'Microsoft Outlook', profiles: ['work'] },
    { app: '/Applications/iTerm.app', profiles: ['work','home'] },
    { app: 'Visual Studio Code', profiles: ['work']},
    { app: 'Calendar', profiles: [] },
    { app: 'Evernote', profiles: ['home'] },
    { app: 'Google Chrome', profiles: ['home'] },  
    { app: 'Firefox', profiles: ['home'] },
    { app: 'Brave Browser', profiles: [] },
    { app: 'Todoist', profiles: ['work','home'] },
    { app: 'TweetDeck', profiles: ['work','home'] },
    { app: 'Slack', profiles: ['work','home'] },
    #{ app: 'Microsoft Teams', profiles: ['work'] },
    { app: 'Microsoft OneNote', profiles: ['work'] },
    { app: 'Numi', profiles: ['work','home'] },
    { app: '/Users/dbayer/Applications/Edge Apps.localized/Todoist.app', profiles: ['work'] },
    { app: '/Users/dbayer/Dropbox/Applications/Launch Outlook.app', profiles: ['work'] },
    { app: '/Users/dbayer/Dropbox/Applications/Outlook Empty Deleted Items.app', profiles: ['work'] },
    { app: '/Users/dbayer/Dropbox/Applications/Outlook Empty Sent Items.app', profiles: ['work'] }
]

(apps.select {|a| a[:profiles].include?("#{current_env}")}).each do |a|
    begin
        system("open","-a",a[:app]) if `ps aux | grep #{a[:app]} | grep -v grep` == ""
    rescue
        `/usr/bin/osascript -e "display notification \"Failed to launch #{a[:app]}\""`
    end
end

