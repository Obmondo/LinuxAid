# Matches valid IPv4 CIDR Mask addresses
# Base Regex taken from Ruby core's Resolv::IPv4::Regex
#
# Reference: ruby/lib/resolv.rb
#
# Copyright 2010 Tanaka Akira <kr@fsij.org>
# Released under the guidance of the Ruby COPYING file section 2(a)
# Commit 4e3a98d383eb3c420df5208d83f9aba70b504e33
#
type Simplib::IP::V4::CIDR = Pattern['^(?-mix:\A((?x-mi:0|1(?:[0-9][0-9]?)?|2(?:[0-4][0-9]?|5[0-5]?|[6-9])?|[3-9][0-9]?))\.((?x-mi:0|1(?:[0-9][0-9]?)?|2(?:[0-4][0-9]?|5[0-5]?|[6-9])?|[3-9][0-9]?))\.((?x-mi:0|1(?:[0-9][0-9]?)?|2(?:[0-4][0-9]?|5[0-5]?|[6-9])?|[3-9][0-9]?))\.((?x-mi:0|1(?:[0-9][0-9]?)?|2(?:[0-4][0-9]?|5[0-5]?|[6-9])?|[3-9][0-9]?))/(3[012]|[12][0-9]|[0-9])\z)$']
