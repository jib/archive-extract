use ExtUtils::MakeMaker;
use strict;

WriteMakefile (
    NAME            => 'Archive::Extract',
    VERSION_FROM    => 'lib/Archive/Extract.pm', # finds $VERSION
    dist            => { COMPRESS => 'gzip -9f', SUFFIX => 'gz' },
    PREREQ_PM       => { 
                        'IPC::Cmd'                  => 0.29,
                        'Test::More'                => 0, 
                        'File::Spec'                => 0.82,
                        'File::Path'                => 0,
                        'File::Basename'            => 0,
                        'Params::Check'             => 0.07,
                        'Module::Load::Conditional' => 0.04,
                        'Locale::Maketext::Simple'  => 0,
                    },
    AUTHOR          => 'Jos Boumans <kane[at]cpan.org>',
	ABSTRACT        => 'Generic archive extracting mechanism'
);     
