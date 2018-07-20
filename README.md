# Ansible-Provision

My Ansible backup playbooks with all my favorite apps and their config
to set up a freshly installed `Ubuntu` machine.
Tested on `Ubuntu GNOME 17.10`.

This repo properly install packages and pull the dotfiles
(configuration files) from my other repos
([dotfiles](https://github.com/joegnis/dotfiles) and
[dotfiles\_local](https://github.com/joegnis/dotfiles_local).
It depends on dotfiles but does NOT include them.

## [Table of Contents](#table-of-contents)

* [Included Softwares](#included-softwares)
  * [Needed to Be Done Manually](#needed-to-be-done-manually)
* [Provisioning](#provisioning)
  * [Preparation on a Host Machine](#preparation-on-a-host-machine)
  * [Preparation on the Control Machine](#preparation-on-the-control-machine)
  * [Add Target Machine to Hosts](#add-target-machine-to-hosts)
  * [Run a Playbook](#run-a-playbook)
* [Development](#development)
  * [Set Up the Environment](#set-up-the-environment)
    * [Use Vagrant](#use-vagrant)
  * [Create a Separate Playbook for Debugging](#create-a-separate-playbook-for-debugging)
  * [Debugging dotfiles](#debugging-dotfiles)
  * [Debugging Tips](#debugging-tips)

## Included Softwares

I roughly put apps into categories, each of which has its own Ansible role.

Check the file `tasks/main.yml` under each role for a list of apps.

### Needed to Be Done Manually

Checkout personal notes.

After provisioning on a new machine:

* Set up default applications
* Regenerate SSH key and set up public key on several hosts
  * Github
  * NAS
* Remove the line added in the file opened by `sudo visudo`
* Re-add VirtualBox VM
  * Install VirtualBox Extension Pack for USB 2.0 Support. The version *must* match that of the VirtualBox installed. Download [here](https://www.virtualbox.org/wiki/Download_Old_Builds_5_1).

## Provisioning

### Preparation on a Host Machine

1. Make sure the user is the administrator and let it sudo without password.
Add a line to the END of the file opened by running `sudo visudo`:

        username ALL=(ALL) NOPASSWD: ALL

2. Install `openssh-server` to allow remote connection:

        sudo apt install openssh-server

3. Install Python 2.7

### Preparation on the Control Machine

1. Install SSH client.
2. Create SSH keys if it doesn't have them.

        ssh-keygen

3. Try running `ssh user@remote_host` to comfirm SSH is working.
4. Copy the public key to the remote

        ssh-copy-id user@remote_host

5. Install Ansible.

### Add Target Machine to Hosts

Edit file [`hosts`](hosts) to add a line of the machine's hostname.

And create a file named same as the hostname in [`host_vars/`](host_vars),
and add necessary variables.

### Run a Playbook

ATTENTION: Better keep logged out when doing the provisioning, otherwise
some GSettings may not be applied.

Either run the main playbook like

```bash
ansible-playbook -i hosts main.yml --limit home_server --tags debug
```

or create a separate playbook to run.

## Development

### Set Up the Environment

Need at least [Ansible](http://docs.ansible.com/ansible/latest/intro_installation.html)
and [VirtualBox](https://www.virtualbox.org/wiki/Downloads) to develop and test locally.

If a corresponding [Vagrant](https://www.vagrantup.com/docs/installation/)
[box](https://app.vagrantup.com/boxes/search) can be found, it would be the best because
provisioning can be automated.

#### Use Vagrant

Start the VM and provision it (using the Vagrant file in the repo).

```bash
vagrant up
```

Optionally, install Vagrant plugin
[vagrant-triggers](https://github.com/emyl/vagrant-triggers)
to automatically remove the VM from SSH known\_hosts.

```bash
vagrant plugin install vagrant-triggers
```

### Create a Separate Playbook for Debugging

A playbook like the following would be helpful for debugging. It limits hosts to the VM.

```yaml
---
- hosts: local_vagrant
  roles:
    - common
    - dotfiles
    - ...
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

