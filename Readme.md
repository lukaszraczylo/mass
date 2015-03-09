# Mass - AWS devops thingy.

### What does mass do?
It simply lists your instances together with basic informations.
Feel free to submit new PRs as it's my side project :P

### Installation

* run ./installer.sh
* to upgrade run mass-updater ( it's an installer but moved to /usr/local/bin )

### Configuration
You can add as many provider_zones as you want. Drop all the configuration in **~/.config.yaml** or file of your choice which can be specified with --config switch.

```
provider_zones:
  first_account:
    aws_access_key_id: 'myKey'
    aws_secret_access_key: 'mySecret'
    cloud: 'aws'
    region: 'eu-west-1'
  second_account:
    cloud: 'aws'
    region: 'eu-west-1'
    aws_access_key_id: 'myKey2'
    aws_secret_access_key: 'mySecret2'
```

### Running

Use following to show usage info
```
$ mass -h
```

### Roadmap

* filtering list of instances by any field
* add filtering by region
* make SSH switch work