
# Set up tests and strictness

use Test::More tests => 37;
use strict;
use warnings;

# Make sure we have all the support routines
# Initialize class for ease of use
# Initialize class for inactive version

require 'testlib';
my $class = 'Cache::Memcached::Managed::Inactive';
(my $multi = $class) =~ s#::Inactive#::Multi#;

# Make sure we can load the module, both active and inactive

require_ok( $_ ) foreach $class,$multi;

# Create inactive cache objects directly
# Make sure we got right objects

my @cache = map {$class->new} 0..2;
isa_ok( $cache[$_],$class,"Check whether object #$_ ok" ) foreach 0..2;

# Create a multi object
# Make sure we have a multi object
# Check all the methods on this object

my $self = $multi->new( @cache );
isa_ok( $self,$multi,"Check whether multi object ok" );
check_methods( $self );

#-------------------------------------------------------------------------
# check_methods
#
# Check whether all the methods are indeed inactive.  Good for 32 tests.
#
#  IN: 1 instantiated object

sub check_methods {

# Obtain the object
# Check methods returning undef always

    my $self = shift;
    is_deeply( scalar( $self->$_ ),
               [undef,undef,undef],
               "Check result of inactive method $_" ) foreach qw(
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

# Check all methods that always return a hash ref

    is_deeply( scalar( $self->$_ ),[{},{},{}],,"Check result of hash ref method $_" )
     foreach qw(
 errors
 get_group
 get_multi
 grab_group
 group
 stats
 version
    );

# Check all methods returning a list in array context

    is_deeply( [$self->$_],[[],[],[]],"Check result of list list method $_" )
     foreach qw(
 dead
 group_names
 servers
    );

# Check all methods returning a hash ref in scalar context

    is_deeply( scalar( $self->$_ ),[{},{},{}],"Check result of scalar inactive method $_")
     foreach qw(
 dead
 group_names
 servers
    );
} #check_methods
