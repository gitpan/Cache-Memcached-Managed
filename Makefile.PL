use strict;
use ExtUtils::MakeMaker;
eval "use Devel::Required";

WriteMakefile (
 NAME		=> "Cache::Memcached::Managed",
 AUTHOR		=> 'Elizabeth Mattijsen (liz@dijkmat.nl)',
 ABSTRACT	=> 'provide API for managing cached information',
 VERSION_FROM	=> 'lib/Cache/Memcached/Managed.pm',

 PREREQ_PM	=> {qw(
                    Cache::Memcached	0
		    Scalar::Util	0
                   )},
);
