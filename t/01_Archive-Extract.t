BEGIN { 
    if( $ENV{PERL_CORE} ) {
        chdir '../lib/Archive/Extract' if -d '../lib/Archive/Extract';
        unshift @INC, '../../..', '../../../..';
    }
}    

BEGIN { chdir 't' if -d 't' };
BEGIN { mkdir 'out' unless -d 'out' };

use strict;
use lib qw[../lib];

use Cwd                         qw[cwd];
use Test::More                  qw[no_plan];
use File::Spec;
use File::Spec::Unix;
use File::Path;
use Data::Dumper;
use Module::Load::Conditional   qw[check_install];

### uninitialized value in File::Spec warnings come from A::Zip:
# t/01_Archive-Extract....ok 135/0Use of uninitialized value in concatenation (.) or string at /opt/lib/perl5/5.8.3/File/Spec/Unix.pm line 313.
#         File::Spec::Unix::catpath('File::Spec','','','undef') called at /opt/lib/perl5/site_perl/5.8.3/Archive/Zip.pm line 473
#         Archive::Zip::_asLocalName('') called at /opt/lib/perl5/site_perl/5.8.3/Archive/Zip.pm line 652
#         Archive::Zip::Archive::extractMember('Archive::Zip::Archive=HASH(0x9679c8)','Archive::Zip::ZipFileMember=HASH(0x9678fc)') called at ../lib/Archive/Extract.pm line 753
#         Archive::Extract::_unzip_az('Archive::Extract=HASH(0x966eac)') called at ../lib/Archive/Extract.pm line 674
#         Archive::Extract::_unzip('Archive::Extract=HASH(0x966eac)') called at ../lib/Archive/Extract.pm line 275
#         Archive::Extract::extract('Archive::Extract=HASH(0x966eac)','to','/Users/kane/sources/p4/other/archive-extract/t/out') called at t/01_Archive-Extract.t line 180
#BEGIN { $SIG{__WARN__} = sub { require Carp; Carp::cluck(@_) } };

if( $^O =~ /(?:cygwin|win32)/i ) {
    diag( "Older versions of Archive::Zip may cause File::Spec warnings" );
    diag( "See bug #19713 in rt.cpan.org. It is safe to ignore them" );
}

my $Debug   = $ARGV[0] ? 1 : 0;

my $Class   = 'Archive::Extract';
my $Self    = File::Spec->rel2abs( cwd() );
my $SrcDir  = File::Spec->catdir( $Self,'src' );
my $OutDir  = File::Spec->catdir( $Self,'out' );

use_ok($Class);

### set verbose if debug is on ###
### stupid stupid silly stupid warnings silly! ###
$Archive::Extract::VERBOSE  = $Archive::Extract::VERBOSE = $Debug;
$Archive::Extract::WARN     = $Archive::Extract::WARN    = $Debug ? 1 : 0;

my $tmpl = {
    ### plain files
    'x.bz2' => {    programs    => [qw[bunzip2]],
                    modules     => [undef],
                    method      => 'is_bz2',
                    outfile     => 'a',
                },
    'x.tgz'     => {    programs    => [qw[gzip tar]],
                        modules     => [qw[Archive::Tar IO::Zlib]],
                        method      => 'is_tgz',
                        outfile     => 'a',
                    },
    'x.tar.gz' => {     programs    => [qw[gzip tar]],
                        modules     => [qw[Archive::Tar IO::Zlib]],
                        method      => 'is_tgz',
                        outfile     => 'a',
                    },
    'x.tar' => {    programs    => [qw[tar]],
                    modules     => [qw[Archive::Tar]],
                    method      => 'is_tar',
                    outfile     => 'a',
                },
    'x.gz' => {     programs    => [qw[gzip]],
                    modules     => [qw[Compress::Zlib]],
                    method      => 'is_gz',
                    outfile     => 'a',
                },
    'x.zip' => {    programs    => [qw[unzip]],
                    modules     => [qw[Archive::Zip]],
                    method      => 'is_zip',
                    outfile     => 'a',
                },
    'x.jar' => {    programs    => [qw[unzip]],
                    modules     => [qw[Archive::Zip]],
                    method      => 'is_zip',
                    outfile     => 'a',
                },                
    'x.par' => {    programs    => [qw[unzip]],
                    modules     => [qw[Archive::Zip]],
                    method      => 'is_zip',
                    outfile     => 'a',
                },                
    ### with a directory
    'y.tbz'     => {    programs    => [qw[bunzip2 tar]],
                        modules     => [undef],
                        method      => 'is_tbz',
                        outfile     => 'z',
                        outdir      => 'y'
                    },
    'y.tar.bz2' => {    programs    => [qw[bunzip2 tar]],
                        modules     => [undef],
                        method      => 'is_tbz',
                        outfile     => 'z',
                        outdir      => 'y'
                    },    
    'y.tgz'     => {    programs    => [qw[gzip tar]],
                        modules     => [qw[Archive::Tar IO::Zlib]],
                        method      => 'is_tgz',
                        outfile     => 'z',
                        outdir      => 'y'
                    },
    'y.tar.gz' => {     programs    => [qw[gzip tar]],
                        modules     => [qw[Archive::Tar IO::Zlib]],
                        method      => 'is_tgz',
                        outfile     => 'z',
                        outdir      => 'y'
                    },
    'y.tar' => {    programs    => [qw[tar]],
                    modules     => [qw[Archive::Tar]],
                    method      => 'is_tar',
                    outfile     => 'z',
                    outdir      => 'y'
                },
    'y.zip' => {    programs    => [qw[unzip]],
                    modules     => [qw[Archive::Zip]],
                    method      => 'is_zip',
                    outfile     => 'z',
                    outdir      => 'y'
                },
    'y.par' => {    programs    => [qw[unzip]],
                    modules     => [qw[Archive::Zip]],
                    method      => 'is_zip',
                    outfile     => 'z',
                    outdir      => 'y'
                },
    'y.jar' => {    programs    => [qw[unzip]],
                    modules     => [qw[Archive::Zip]],
                    method      => 'is_zip',
                    outfile     => 'z',
                    outdir      => 'y'
                },
    ### with non-same top dir
    'double_dir.zip' => {
                    programs    => [qw[unzip]],
                    modules     => [qw[Archive::Zip]],
                    method      => 'is_zip',
                    outfile     => 'w',
                    outdir      => 'x'
                },
};


for my $switch (0,1) {
    local $Archive::Extract::PREFER_BIN = $switch;
    diag("Running extract with PREFER_BIN = $Archive::Extract::PREFER_BIN")
        if $Debug;


    for my $archive (keys %$tmpl) {

        diag("Extracting $archive") if $Debug;

        ### check first if we can do the proper

        my $ae = Archive::Extract->new(
                        archive => File::Spec->catfile($SrcDir,$archive) );

        isa_ok( $ae, $Class );

        my $method = $tmpl->{$archive}->{method};
        ok( $ae->$method(),         "Archive type recognized properly" );

    ### 10 tests from here on down ###
    SKIP: {
        my $file        = $tmpl->{$archive}->{outfile};
        my $dir         = $tmpl->{$archive}->{outdir};  # can be undef
        my $rel_path    = File::Spec->catfile( grep { defined } $dir, $file );
        my $abs_path    = File::Spec->catfile( $OutDir, $rel_path );
        my $abs_dir     = File::Spec->catdir( 
                            grep { defined } $OutDir, $dir );
        my $nix_path    = File::Spec::Unix->catfile(
                            grep { defined } $dir, $file );

        ### check if we can run this test ###
        my $pgm_fail; my $mod_fail;
        for my $pgm ( @{$tmpl->{$archive}->{programs}} ) {
            ### no binary extract method
            $pgm_fail++, next unless $pgm;

            ### we dont have the program
            $pgm_fail++ unless $Archive::Extract::PROGRAMS->{$pgm} &&
                               $Archive::Extract::PROGRAMS->{$pgm};

        }

        for my $mod ( @{$tmpl->{$archive}->{modules}} ) {
            ### no module extract method
            $mod_fail++, next unless $mod;

            ### we dont have the module
            $mod_fail++ unless check_install( module => $mod );
        }


        ### where to extract to -- try both dir and file for gz files
        ### XXX test me!
        #my @outs = $ae->is_gz ? ($abs_path, $OutDir) : ($OutDir);
        my @outs = $ae->is_gz || $ae->is_bz2 ? ($abs_path) : ($OutDir);

        skip "No binaries or modules to extract ".$archive, 
            (10 * scalar @outs) if $mod_fail && $pgm_fail;

        for my $use_buffer (1,0) {

            ### test buffers ###
            my $turn_off = !$use_buffer && !$pgm_fail &&
                            $Archive::Extract::PREFER_BIN;

            ### whitebox test ###
            ### stupid warnings ###
            local $IPC::Cmd::USE_IPC_RUN    = 0 if $turn_off;
            local $IPC::Cmd::USE_IPC_RUN    = 0 if $turn_off;
            local $IPC::Cmd::USE_IPC_OPEN3  = 0 if $turn_off;
            local $IPC::Cmd::USE_IPC_OPEN3  = 0 if $turn_off;


            ### try extracting ###
            for my $to ( @outs ) {

                diag("Extracting to: $to")                  if $Debug;
                diag("Buffers enabled: ".!$turn_off)        if $Debug;
    
                my $rv = $ae->extract( to => $to );
    
                ok( $rv, "extract() for '$archive' reports success");
    
                diag("Extractor was: " . $ae->_extractor)   if $Debug;
    
                SKIP: {
                    skip "No buffers available", 6,
                        if $ae->error =~ /^No buffer captured/;
    
                    ### might be 1 or 2, depending wether we extracted 
                    ### a dir too
                    my $file_cnt = grep { defined } $file, $dir;
                    is( scalar @{ $ae->files || []}, $file_cnt,
                                    "Found correct number of output files" );
                    is( $ae->files->[-1], $nix_path,
                                    "Found correct output file '$nix_path'" );
    
                    ok( -e $abs_path,
                                    "Output file '$abs_path' exists" );
                    ok( $ae->extract_path,
                                    "Extract dir found" );
                    ok( -d $ae->extract_path,
                                    "Extract dir exists" );
                    is( $ae->extract_path, $abs_dir,
                                    "Extract dir is expected '$abs_dir'" );
                }
    
                1 while unlink $abs_path;
                ok( !(-e $abs_path), "Output file successfully removed" );
    
                SKIP: {
                    skip "No extract path captured, can't remove paths", 2
                        unless $ae->extract_path;
    
                    eval { rmtree( $ae->extract_path ) }; 
                    ok( !$@,        "   rmtree gave no error" );
                    ok( !(-d $ae->extract_path ),
                                    "   Extract dir succesfully removed" );
                }
            }
        }
    } }
}



