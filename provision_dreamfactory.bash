#!/bin/bash

set -e
set -u

install_packages () {
  local missing_packages=()
  for package in "$@" ; do
    if ! rpmquery --quiet "$package" ; then
      missing_packages+=( "$package" )
    fi
  done
  if [ ${#missing_packages[@]} -gt 0 ] ; then
    yum -y install "${missing_packages[@]}"
  fi
}

install_packages epel-release
install_packages ansible

cd /vagrant/playbooks
rm -rf /etc/ansible/roles/mcenirm.{postgresql94-server,php70}
ansible-galaxy install mcenirm.postgresql94-server,v0.1.2
ansible-galaxy install mcenirm.php70,v0.1.5
ansible-playbook --syntax-check deploy_dreamfactory.yml
ansible-playbook \
  -v \
  -e 'dist_dir=/vagrant/dist' \
  -e 'df_user=vagrant' \
  -e 'df_install_dir=/home/vagrant' \
  deploy_dreamfactory.yml
