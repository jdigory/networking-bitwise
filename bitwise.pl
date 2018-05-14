#!/usr/bin/env perl

use strict;
use warnings;
use 5.010;

# https://en.wikipedia.org/wiki/Subnetwork#Internet_Protocol_version_4
#
# https://stackoverflow.com/questions/483655/how-do-i-convert-a-binary-string-to-a-number-in-perl#483708

print "Enter an IP address in CIDR notation: ";
my $address = <STDIN>;

my ( $ip, $cidr ) = split '/', $address;
my $bin_ip          = ip2binary($ip);
my $bin_subnet_mask = cidr2bin($cidr);
my $net_prefix      = $bin_ip & $bin_subnet_mask;
my $mask_ones_comp  = my1scomp($bin_subnet_mask);
my $host_part       = $bin_ip & $mask_ones_comp;

say "ip: $ip";
say "binary ip: " . bin_dotted($bin_ip);
say "";
say "subnet mask: " . ip2dec( bin_dotted($bin_subnet_mask) );
say "binary subnet mask: " . bin_dotted($bin_subnet_mask);
say "";
say "how many addresses? " . 2**(32-$cidr);
say "";
say "network prefix: " . ip2dec( bin_dotted($net_prefix) );
say "binary network prefix: " . bin_dotted($net_prefix);
say "";
say "ones complement of binary subnet mask: " . bin_dotted($mask_ones_comp);
say "";
say "host part: " . ip2dec( bin_dotted($host_part) );
say "binary host part: " . bin_dotted($host_part);
say "offset: " . oct( "0b" . $host_part );

sub ip2binary {
    # convert each decimal octet to binary
    my $ip = shift;
    my @octets;
    push @octets, sprintf "%.8b", $_ for split /\./, $ip;
    return join '', @octets;
}

sub ip2dec {
    my @d;
    push @d, oct("0b" . $_) for split /\./, shift; 
    return join '.', @d;
}

sub cidr2bin {
    my $cidr = shift;
    my $bits = 32;
    my $bin_ip = (1 x $cidr) . (0 x (32-$cidr));
    return $bin_ip;
}

sub bin_dotted {
    my $bits = shift;
    my $dotted;
    my $i = 1;
    for (split(//, $bits)) {
        $dotted .= $_;
        last if $i == 32;
        $dotted .= '.' if $i % 8 == 0;
        $i++;
    }
    return $dotted;
}

sub my1scomp {
    my $ip = shift;
    my @octets;
    for ( split /\./, $ip ) {
        my @bits;
        for (split //) {   # handle each bit singly of the 8 bits 
            $_ == 1 ? y/1/0/ : y/0/1/;
            push @bits, $_;
        }
        push @bits, '.';
        push @octets, @bits;
    }
    return join '', @octets;
}
