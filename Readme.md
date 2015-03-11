# Mass - AWS devops thingy.

### What does mass do?
It simply lists your instances together with basic informations.
Feel free to submit new PRs as it's my side project :P

### Installation

I assume you have homebrew and some recent version of ruby interpreter together with ruby gems installed.

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

Mass is a simple tool for DevOps created to make cloud infrastructure management easy.
Usage:
      $ mass [options]

where [options] are:
  -a, --all                        Show all the accounts, no filtering, no accounts and clouds separation.
  -c, --account=<s>                Cloud account set in your configuration file
  -l, --cloud=<s>                  Cloud service you'd like to use. Must comply with your settings file.
  -o, --config=<s>                 Configuration file path. If non specified - using ~/.config.yaml
  -d, --debug=<i>                  Debug and its level. Lower debug level equals to less information printed. (Default: 0)
  -f, --filter=<s>                 Filtering results. Please refer to README.md for filters documentation.
  -r, --raw=<s>                    Printing out without tables, separator of your choice. (Default: ;;)
  -e, --region=<s>                 Cloud account region to use
  -x, --external                   Use external IP ( for SSH )
  -i, --internal, --no-internal    Use internal IP ( for SSH ) (default: true)
  -s, --ssh                        Open SSH connection to all the results
  -v, --version                    Print version and exit
  -h, --help                       Show this message
```


### Examples

#### Filtering by field ( woohoo, regexp power! )
```
mass --account potato --filter "size::.*micro"
mass --account banana --filter "hostname::^master.*" -d
```

#### Filtering by multiple fields
```
mass --account minions --filter "size::.*micro,,hostname::natbox"
```

### Roadmap

* add filtering by region
* fix displaying filters even when different cloud is specified