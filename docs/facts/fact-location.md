# Custom Puppet Fact: `location`

## Overview

The `location` custom fact is used to determine the location of a node based on its IP address. This fact maps IP addresses to locations and sets the location as a fact in Puppet, which can be utilized in Hiera or other Puppet modules.

## Fact Definition

The location fact determines the node's location by checking if its IP address falls within any of the specified IP ranges. The IP ranges must be provided in valid CIDR format. Based on this check, the appropriate location is assigned to the location fact. This fact value can then be used to configure settings via Puppet's hocon_setting resource.

## Configuration

**Define Locations and IP Ranges:**

In your Hiera configuration, you need to specify the locations and corresponding IP ranges. For example:

```yaml
common::system::locations:
    Sheffield:
    - 10.106.0.0/18
```
