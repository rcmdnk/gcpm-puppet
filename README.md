# gcpm-puppet

Puppet configurations for
HTCondor manager host and HTCondor worker node template,
which is used by [gcp_condor_pool_manager (gcpm)](https://github.com/mickaneda/gcp_condor_pool_manager).

## Environments

These puppet settings are for:

* CentOS 7
* Puppet 5

## HOSTNAME

Manager's HOSTNAME should be `gcp-ce*`.
Worker node template's HOSTNAME should be `gcp-wn*`.

If you want to use different names, modify **./etc/puppetlabs/code/environments/production/manifests/site.pp**.

## Setup

Install puppet and files by:

    # ./setup.sh

To apply manifests, do:

    # /opt/puppetlabs/bin/puppet apply /etc/puppetlabs/code/environments/production/manifests/site.pp --verbose

## Server/Agent

If you setup puppet server, do

    # ./setup.sh -s

otherwise, do:

    # ./setup.sh

To apply local manifests, do:

    # /opt/puppetlabs/bin/puppet apply /etc/puppetlabs/code/environments/production/manifests/site.pp --verbose

If you want to use server's settings in other machines, install puppet:

    # rpm -Uvh https://yum.puppetlabs.com/puppet5/puppet5-release-el-7.noarch.rpm
    # yum install -y puppet-agent

and apply server's manifests. First do at client:

    # /opt/puppetlabs/bin/puppet agent --test --server <server>

Then, go server, and do:

    # /opt/puppetlabs/bin/puppet cert sign <client>

Now you can install by using same command above at client:

    # /opt/puppetlabs/bin/puppet agent --test --server <server>

or add followings in **/etc/puppetlabs/puppet/puppet.conf** to identify server:

    [main]
    certname = <client>
    server = <server>
    environment = production
    runinterval = 1h

and do

    # /opt/puppetlabs/bin/puppet agent --test
