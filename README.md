# Dav's Dotfiles

## What

This is me getting tired of recreating my bash profile every time I get a new computer.

## How

* Folder `.bash.d` (can be changed during setup) is used for all the things
* Folder `.bash.d/profiles` contains the common profile that is always loaded and any environment specific profiles you desire. Be careful not to push any sensitive information to public repos, including proprietary information for your place of business.
* Folder `.bash.d/safety-zone` is for sensitive data that should not be published to any hosted repo either public or work. Passwords, ssh keys, API keys, etc. can safely reside in this folder.

`.gitignore` is set to ignore the `safety-zone` folder with the exception of the `README` files. Other undesirables can also be listed here.

## Setup

For easy setup, run `setup/setup.sh` which will do the following:
* Clone this git repo
* Allow selection of the desired specific profile to load
* Read `setup/links.csv` to create any required symlinks
* Reload the shell environment

```
Usage: setup.sh [-b] [-d DEST_DIR] [-y] [-h]

    -b            Backup all items that would be overridden
    -d DEST_DIR   Specify alternate directory for dotfiles
    -p PROFILE    Specify bash profile for this computer
    -y            Respond yes to all prompts
    -h            Display this help message
```

Copy the file `setup/setup.sh` from github to the local file system and run it. Note that you will need to have an SSH key on the local system that has been added to github in order to clone the dotfiles repo.
