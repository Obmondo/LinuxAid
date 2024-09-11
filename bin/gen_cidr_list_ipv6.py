#!/usr/bin/env python3

import csv
import sys
import ipaddress  # NOTE: this is in stdlib


def decimal_to_ipv6(decimal):
    if str(decimal).isdigit() is False:
        return
    result = ipaddress.IPv6Address(int(decimal))
    if result.ipv4_mapped != None:
        return "::ffff:" + str(result.ipv4_mapped)
    else:
        return str(result)


if __name__ == "__main__":

    if len(sys.argv) < 3:
        raise Exception(
            "Arguments not provided. ARG1: Path to db ARG2: Country moniker"
        )

    ip2loc_db = sys.argv[1]
    chosen_country_moniker = sys.argv[2]

    with open(ip2loc_db, "r") as f:
        ip_list = csv.reader(f)
        for row in ip_list:
            range_start = ipaddress.IPv6Address(decimal_to_ipv6(int(row[0])))
            range_end = ipaddress.IPv6Address(decimal_to_ipv6(int(row[1])))
            country_moniker = row[2]

            if country_moniker == chosen_country_moniker:
                for addr in ipaddress.summarize_address_range(range_start, range_end):
                    print(addr)
