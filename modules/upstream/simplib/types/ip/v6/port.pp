# Matches valid Bracketed IPv6 addresses with Port specification
# Base Regex taken from Ruby core's Resolv::IPv6::Regex
# Reference: ruby/lib/resolv.rb
#
# Copyright 2010 Tanaka Akira <kr@fsij.org>
# Released under the guidance of the Ruby COPYING file section 2(a)
# Commit 4e3a98d383eb3c420df5208d83f9aba70b504e33
#
type Simplib::IP::V6::Port = Pattern['^(?x-mi:(?:(?x-mi:\A\[(?:[0-9A-Fa-f]{1,4}:){7}[0-9A-Fa-f]{1,4}\]:([0-9]{1,4}|[1-5][0-9]{4}|6[0-4][0-9]{3}|65[0-4][0-9]{2}|655[0-2][0-9]|6553[0-5])\z))|(?:(?x-mi:\A\[((?:[0-9A-Fa-f]{1,4}(?::[0-9A-Fa-f]{1,4})*)?)::((?:[0-9A-Fa-f]{1,4}(?::[0-9A-Fa-f]{1,4})*)?)\]:([0-9]{1,4}|[1-5][0-9]{4}|6[0-4][0-9]{3}|65[0-4][0-9]{2}|655[0-2][0-9]|6553[0-5])\z))|(?:(?x-mi:\A\[((?:[0-9A-Fa-f]{1,4}:){6,6})(\d+)\.(\d+)\.(\d+)\.(\d+)\]:([0-9]{1,4}|[1-5][0-9]{4}|6[0-4][0-9]{3}|65[0-4][0-9]{2}|655[0-2][0-9]|6553[0-5])\z))|(?:(?x-mi:\A\[((?:[0-9A-Fa-f]{1,4}(?::[0-9A-Fa-f]{1,4})*)?)::((?:[0-9A-Fa-f]{1,4}:)*)(\d+)\.(\d+)\.(\d+)\.(\d+)\]:([0-9]{1,4}|[1-5][0-9]{4}|6[0-4][0-9]{3}|65[0-4][0-9]{2}|655[0-2][0-9]|6553[0-5])\z)))$']
