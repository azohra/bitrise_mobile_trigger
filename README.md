# Mobile Trigger [![Build Status](https://travis-ci.org/azohra/bitrise_mobile_trigger.svg?branch=master)](https://travis-ci.org/azohra/bitrise_mobile_trigger)

Mobile Trigger is a command line bitrise client, used to trigger workflows on [Bitrise](https://www.bitrise.io). It can be used as a standalone tool for triggering jobs but primarily intended to be used in combination with continuous integration systems like Bamboo CI or [Gitlab CI](https://about.gitlab.com/features/gitlab-ci-cd/).



## Installation

Download the platform specific binary file from the release/tags page, and place the binary in the project you are building.



## Usage

> Usage: bitriseTrigger \[flag\] \[options\]
>
> -V --version  - Version of cli running.
> -w --workflow-id WORKFLOW_ID - Bitrise workflow id.
> -b --branch BRANCH_NAME - Name of the branch to be built.
> -c --config CONFIG_PATH - Absolute path of to configuration file.
>
>  -h --help  - Prints this help message

The mobile trigger application must be given a configuration file. For example:

```json
{
	"theAccessToken": "give the access token here, e.g. sdvsdfvsdvk3246823t9",
	"token": "given project api token here, e.g. ED34r3DsW33",
	"slug": "the project api slug goes here, e.g. TE78gsdsUUop22",
	"projectName": "The name of the project given here"
}
```

Use the mandatory configuration flag `-c` or `—config` to specify the absolute path to the configuration file. An overall example of use would be:

```shell
./bitriseTrigger -w UnitTest -b develop --config /User/name/myproject/config.json
```



## Contributing

Bug reports and pull requests are welcome. Note that if you are reporting a bug then make sure to include a failing spec that highlights an example of the bug. This project is intended to be a safe, welcoming space for collaboration, and contributors are expected to adhere to the [Contributor Covenant](http://contributor-covenant.org/) code of conduct.



## License

This software is available as open source under the terms of the *MIT License*.