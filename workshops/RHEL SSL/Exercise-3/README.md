# Using SSL/TLS with IPsec VPN

Today the very basic of securing your application is running it with a TLS encryption, the new ones.
Unfortunately , there are still a lot of old application in the organization that are running over clear text such as old Java application for API and in some cases even telnet in some FSI organization.

Luckily there is a very nice and easy fix which is to configure a VPN tunnel between the 2 server which enable the data to go through an encrypted tunnel.

## What do we need ?

In RHEL 9 there is a package called libreswan which we can use for the P2P VPN configuration.

**NOTE**
In some cases we can use the 2 servers as routers and then we can add a static route between 2 networks.

## Install libreswan

Before you can set a VPN through the Libreswan IPsec/IKE implementation, you must install the corresponding packages, start the ipsec service, and allow the service in your firewall. 

##### Prerequisites
- The AppStream repository is enabled. 

##### Procedure



You have completed your Exercise !!!