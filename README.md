# Ansible-Provision

My Ansible playbooks with all my faves to set up a `Ubuntu` machine.
Tested on `Ubuntu GNOME 17.04`.

This repo properly install packages and pull the dotfiles
(configuration files) from my other repos
([dotfiles](https://github.com/joegnis/dotfiles) and
[dotfiles\_local](https://github.com/joegnis/dotfiles_local).
It does NOT include dotfiles. It's supposed to work with dotfiles to work
properly.

## [Table of Contents](#table-of-contents)

* [Included Softwares](#included-softwares)
  * [Needed to Be Done Manually](#needed-to-be-done-manually)
* [Provisioning](#provisioning)
  * [Preparation on a Host Machine](#preparation-on-a-host-machine)
  * [Preparation on the Control Machine](#preparation-on-the-control-machine)
  * [Add Target Machine to Hosts](#add-target-machine-to-hosts)
  * [Run a Playbook](#run-a-playbook)
* [Development](#development)
  * [Set up the environment](#set-up-the-environment)
  * [Create a Separate Playbook for Debugging](#create-a-separate-playbook-for-debugging)
  * [Debugging dotfiles](#debugging-dotfiles)
  * [Debugging Tips](#debugging-tips)

## Included Softwares

I put major ones into individual roles and
minor ones into [misc role](roles/misc/tasks/main.yml).

* `dotfiles`
* `dotfiles_local`, `ubuntu-gnome` branch
* [`bash-it`](https://github.com/Bash-it/bash-it)
* `zsh`
  * [`antigen`](https://github.com/zsh-users/antigen)
* bash and zsh
  * `dircolors`
* `Python`
  * `pyenv` and `pyenv-virtualenv`
* `Vim` and dozens of plugins
* `Neovim` (in transition to it now...)
* `tmux`
  * plugins manager `tpm`
  * session manager `tmuxifier`
* `aria2` run as daemon
  * CMD interface [`diana`](https://github.com/baskerville/diana)
* misc
  * `bd`
  * `ack`, beyond grep
  * `thefuck`, corrects my CMD mistakes
* GNOME
  * Themes
  * Config tools
  * Extensions
  * Settings (using `gsettings` and `dconf`)
  * Rime input method
* Apps
  * Chromium
  * Firefox
  * Atom
  * Dropbox
  * Albert
  * Git GUI
  * Transmission
  * Rhythmbox
  * Corebird
  * GoldenDict
  * MComix
  * SMPlayer
  * Telegram Desktop
  * Zeal
  * VirtualBox

### Needed to Be Done Manually

* Backup and Restore SSH config file (`~/.ssh/config`)
* Backup and Restore Personal files
  * Music and playlists (and import them in Rythmbox)
* Backup and Restore Atom by using sync-settings package
* Backup and Restore dictionaries in GoldenDict
  * Restore: Let it build the index after it the first boot
* Backup and Restore Chrome Extensions data which are not synced by Google
  * OneTab
  * uGet filter list
  * ...

After provisioning on a new machine:

* Set up default applications
* Regenerate SSH key and set up public key on several hosts

## Provisioning

### Preparation on a Host Machine

1. Make sure the user is the administrator and let it sudo without password.
Add a line to the file opened by running `sudo visudo`:

        username ALL=(ALL) NOPASSWD: ALL

2. Install `openssh-server` to allow remote connection:

        sudo apt install openssh-server

### Preparation on the Control Machine

1. Install SSH client.
2. Create SSH keys if it doesn't have them.

        ssh-keygen

3. Try running `ssh user@remote_host` to comfirm SSH is working.
4. Copy the public key to the remote

        ssh-copy-id user@remote_host

### Add Target Machine to Hosts

Edit file [`hosts`](hosts) to match the machine's hostname (or nickname).

And create a file named as the hostname in [`host_vars/`](host_vars),
and add necessary variables.

### Run a Playbook

ATTENTION: Better keep logged out when doing the provisioning, otherwise
some GSettings may not be applied.

Either run the main playbook like

```bash
ansible-playbook -i hosts main.yml --limit home_server
```

or create a separate one to run.

## Development

### Set up the environment

Install [Ansible](http://docs.ansible.com/ansible/latest/intro_installation.html),
[Vagrant](https://www.vagrantup.com/docs/installation/) and
[VirtualBox](https://www.virtualbox.org/wiki/Downloads). Run

```bash
vagrant up
```

to bring Vagrant up. It will start the VM and provision it automatically.

Optionally, install Vagrant plugin
[vagrant-triggers](https://github.com/emyl/vagrant-triggers)

```bash
vagrant plugin install vagrant-triggers
```

to automatically remove the VM from SSH known\_hosts.

### Create a Separate Playbook for Debugging

A playbook like this would be helpful. It limits hosts to the VM.

```yaml
---
- hosts: local_vagrant
  roles:
    - common
    - dotfiles
    - bash
    - zsh
    - tmux
    - python
    - vim
    - misc
```

### Debugging dotfiles

To debug (with) dotfiles, Ansible can be set up to copy local dotfiles repo to
the VM.

Edit [role/dotfiles/vars/main.yml](roles/dotfiles/vars/main.yml) to
set `debug` to `true` and set `local_dotfiles_dir` to the correct local dotfiles
repo.

Alternatively, I can override this variable on the role level. For example,
create a new playbook `dev.yml`:

```yaml
roles:
  - { role: dotfiles, debug: true }
```

### Debugging Tips

* To debug specific roles, create a separate playbook and include them only.
* To debug specific tasks, tag them with syntax `tags: debug` and run the playbook
with: `ansible-playbook -i hosts dev.yml --tags debug`.
* To run the playbook locally, use one like:

        - hosts: 127.0.0.1
          connection: local
          roles:
            - common
            - ...

