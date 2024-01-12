# shellcheck disable=SC2148

# weather info

# put weather info in even numbered terminals and moon phase in odd numbered terminals

# wttr had a problem in 2018 that would sometimes misidentity IP address location
# using geoiplookup to set long/lat could be done like this:
#       curl -s http://wttr.in/$(geoiplookup $(curl -s ifconfig.co) | awk '/City/ {gsub(/,/, ""); print $(NF-3)","$(NF-2)}') | head -17

if [[ ! $(which curl) ]]; then
    install curl
fi

this_tty=$(tty)
if [[ "$((${this_tty: -3} % 2))" -eq "0" ]]; then
    # parameter "1" limits output to today
    # parameter "F" removes the "Follow" output
    curl -s --max-time 1 wttr.in?1Fu
else
    curl -s --max-time 3 www.wttr.in/Moon?F
fi
echo

