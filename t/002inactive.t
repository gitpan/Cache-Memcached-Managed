
# Set up tests and strictness

use Test::More tests => 35;
use strict;
use warnings;

# Make sure we have all the support routines
# Initialize class for ease of use
# Initialize class for inactive version

require 'testlib';
my $class    = 'Cache::Memcached::Managed';
my $inactive = $class.'::Inactive';

# Make sure we can load the module, both active and inactive
# Make sure that all of the methods can be executed

require_ok( $class ) foreach $class,$inactive;

my $cache = $class->new( inactive => 1 );
isa_ok( $cache,$inactive,"Check whether object #1 ok" );

$cache = $inactive->new;
isa_ok( $cache,$inactive,"Check whether object #2 ok" );

ok( !defined( $cache->$_ ),"Check result of inactive method $_" )
foreach qw(
 add
 data
 decr
 delete
 delete_group
 delimiter
 directory
 expiration
 flush_all
 flush_interval
 get
 incr
 namespace
 replace
 reset
 set
 start
 stop
);

is_deeply( $cache->$_,{},"Check result of inactive method $_" )
foreach qw(
 errors
 get_group
 get_multi
 grab_group
 group
 stats
 version
);

is_deeply( [$cache->$_],[],"Check result of list inactive method $_" )
foreach qw(
 dead
 group_names
 servers
);

is_deeply( scalar $cache->$_,{},"Check result of scalar inactive method $_" )
foreach qw(
 dead
 group_names
 servers
);
