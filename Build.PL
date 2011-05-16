use strict;
use warnings;
use Module::Build;

my $builder = Module::Build->new(
    meta_merge => {
        resources => {
            repository => [ 'http://github.com/duncs/perl-app-bk', ],
            bugtracker => 'https://github.com/duncs/perl-app-bk/issues',
            homepage   => 'https://github.com/duncs/perl-app-bk',
        },
    },
    module_name       => 'App::bk',
    license           => 'perl',
    dist_author       => q{Duncan Ferguson <duncan_j_ferguson@yahoo.co.uk>},
    dist_version_from => 'lib/App/bk.pm',
    build_requires    => {
        'Test::More'     => 0,
        'FindBin'        => 0,
        'File::Basename' => 0,
        'Getopt::Long'   => 0,
        'Pod::Usage'     => 0,
        'English'        => 0,
        'POSIX'          => 0,
        'File::Copy'     => 0,
    },
    add_to_cleanup     => ['App-bk-*'],
    create_makefile_pl => 'traditional',
    script_files       => 'bin',
);

$builder->create_build_script();
