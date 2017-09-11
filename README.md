# Ansible-Provision

My Ansible playbooks with all my faves to set up a `Ubuntu` machine.
Tested on `Ubuntu 16.04`.

This repo properly install packages and pull the dotfiles
(configuration files) from my another [repo](https://github.com/joegnis/dotfiles).
It does NOT include dotfiles. It's supposed to work with dotfiles to work
properly.

## Table of Contents

* [Included Softwares](#included-softwares)
* [Provisioning](#provisioning)
  * [Prerequisites](#prerequisites)
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

## Provisioning

### Prerequisites

Install [Ansible](http://docs.ansible.com/ansible/latest/intro_installation.html).

### Add Target Machine to Hosts

Put the machine's hostname (or nickname) in [`hosts`](hosts).

And create a file with the same name as its hostname in [`host_vars/`](host_vars).

### Run a Playbook

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

To debug specific roles, create a separate playbook and include them only.

To debug specific tasks, tag them with syntax `tags: debug` and run the playbook
with: `ansible-playbook -i hosts dev.yml --tags debug`.
