
# Setup test and strictness

use Test::More tests => 23;
use strict;
use warnings;

# Add stopping code, only to be executed in main process

my $cache;
my $filename;
my $pid = $$;
END {
  if ($pid == $$) {
    diag( "\nStopped memcached server" )
     if $cache and ok( $cache->stop,"Check if all servers have stopped" );
  }
} #END

# Make sure we have all the support routines
# Initialize class for ease of use
# Make sure it is loaded

require 'testlib';
my $class = 'Cache::Memcached::Managed';
use_ok( $class );

# Obtain port and create config

my $port = anyport();
ok( $port,"Check whether we have a port to work on" );
my $config = "127.0.0.1:$port";

# Create a cache object

$cache = $class->new( $config );
isa_ok( $cache,$class,"Check whether object ok" );

# Start the server, skip further tests if failed

SKIP: {
skip( "Memcached server not started",19 ) unless $cache->start;
sleep 2; # let the server warm up
diag( "\nStarted memcached server" );

# Set/Get simple value here

my $value = 'value';
ok( $cache->set( $value ),"Check if simple set is ok" );
is( $cache->get,$value,"Check if simple get is ok" );

# Fork, get and set value there

$filename = 'forked';
unless (fork) {
  ft();
  ft( $cache->get eq $value,"Check if simple get in fork is ok" );
  ft( $cache->set( 'foo' ),"Check if simple set in fork is ok" );
  splat( $filename,ft() );
  exit;
}

# Process test results from fork

sleep 3;
pft( $filename );

# Check whether the value from the fork is ok

is( $cache->get,'foo',"Check if simple get after fork is ok" );
ok( $cache->delete,"Check if simple delete after fork is ok" );

# Obtain final stats
# Remove stuff that we can not check reliably

my $got = $cache->stats->{$config};
delete @$got{qw(
 bytes_read
 bytes_written
 connection_structures
 curr_connections
 limit_maxbytes
 pid
 rusage_user
 rusage_system
 time
 total_connections
 uptime 
 version
)};

# Set up the expected stats for the rest

my $expected = {
 bytes       => 0,
 cmd_get     => 3,
 cmd_set     => 2,
 curr_items  => 0,
 get_hits    => 3,
 get_misses  => 0,
 total_items => 2,
};

# Check if it is what we expected

diag( Data::Dumper::Dumper( $got,$expected ) ) unless
 is_deeply( $got,$expected,
  "Check if final stats correct" );

# Stop the server

ok( $cache->stop,"Check if all servers have stopped" );
diag( "\nStopped memcached server" );

# Obtain another port and recreate config

$port = anyport();
ok( $port,"Check whether we have a port to work on" );
$config = "127.0.0.1:$port";

# Create a new cache object

$cache = $class->new( $config );
isa_ok( $cache,$class,"Check whether object ok" );

ok( !$cache->set( $value ),"Check if simple set fails" );

ok( $cache->start,"Check if servers have started again" );
sleep 2;
diag( "\nStarted memcached server" );

ok( !$cache->set( $value ),"Check if simple set still fails" );

unless (fork) {
  ft();
  ft( $cache->set( $value ),"Check if simple set in 2nd fork is ok" );
  ft( $cache->get eq $value,"Check if simple get in 2nd fork is ok" );
  splat( $filename,ft() );
  exit;
}

# Process test results from fork

sleep 3;
pft( $filename );

ok( !$cache->get,"Check if simple get still fails" );
diag( "\nWaiting 30 seconds for server to become eligible again" );
sleep 30;
is( $cache->get,$value,"Check if simple get now successful" );

# Delete the value

ok( $cache->delete,"Check if simple delete after 2nd fork is ok" );

# Obtain final stats
# Remove stuff that we can not check reliably

$got = $cache->stats->{$config};
delete @$got{qw(
 bytes_read
 bytes_written
 connection_structures
 curr_connections
 limit_maxbytes
 pid
 rusage_user
 rusage_system
 time
 total_connections
 uptime 
 version
)};

# Set up the expected stats for the rest

$expected = {
 bytes       => 0,
 cmd_get     => 2,
 cmd_set     => 1,
 curr_items  => 0,
 get_hits    => 2,
 get_misses  => 0,
 total_items => 1,
};

# Check if it is what we expected

diag( Data::Dumper::Dumper( $got,$expected ) ) unless
 is_deeply( $got,$expected,
  "Check if final stats correct" );
} #SKIP
