# Mass - AWS devops thingy.

### What does mass do?
It simply lists your instances together with basic informations.
Feel free to submit new PRs as it's my side project :P

### Installation

* run ./installer.sh
* to upgrade run mass-updater ( it's an installer but moved to /usr/local/bin )

### Configuration
You can add as many provider_zones as you want. Drop all the configuration in **~/.config.yaml**

```
provider_zones:
  first_account:
    aws_access_key_id: 'myKey'
    aws_secret_access_key: 'mySecret'
    default: 'true'
  second_account:
    aws_access_key_id: 'myKey2'
    aws_secret_access_key: 'mySecret2'
```

### Running

```
$ mass
```

Returns list of instances added to your accounts.

### Roadmap

* filtering list of instances by any field