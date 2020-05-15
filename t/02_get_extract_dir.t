
use strict;
use warnings;
use Test::More qw[no_plan];
use File::Basename qw[];
no warnings 'once';
no warnings 'redefine';

#test __get_extract_dir without real files
*File::Spec::catdir = sub {
    shift;
    my $arg = shift;
    $arg =~ s#/$##;
    return $arg;
};
*File::Basename::dirname = sub {
    my $arg = shift;
    $arg =~ s#/[^/]+$##;
    return $arg;
};
*File::Spec::rel2abs = sub {
    shift;
    my $arg = shift;
    return $arg;
};
require Archive::Extract;

#note: test directory names should end with '/'

my $t1 = Archive::Extract::__get_extract_dir('', ['t1/', 't1/test1','t1/test2']);
is($t1, 't1');

my $t2 = Archive::Extract::__get_extract_dir('', ['t1/', 't1/test1','t2/']);
is($t2, '.');
