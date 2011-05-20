package App::bk;

use warnings;
use strict;

use Getopt::Long qw(:config no_ignore_case bundling no_auto_abbrev);
use Pod::Usage;
use English 'no-match-vars';
use POSIX qw(strftime);
use File::Basename;
use File::Copy;
use File::Which qw(which);

=head1 NAME

Module backend for the 'bk' commaned.  Please see its documentation for 
command line usage using one of the following commands:

  bk -h
  bk -H
  bk --man
  man bk
  perldoc bk

=head1 VERSION

Version 0.01

=cut

our $VERSION = '0.01';

my %opts = (
    'help|h|?'    => 0,
    'man'         => 0,
    'version|V'   => 0,
    'debug:+'     => 0,
    'directory|d' => 0,
);
my %options;

=head1 SYNOPSIS

Backend for bk command - does the actualy work.  'bk' is just a very light
interface into this module, where the real work is done.


    use App::bk;

    my $foo = App::bk->backup_files();

=head1 SUBROUTINES/METHODS

=head2 backup_files

Main function to process ARGV and backup files as necessary

=cut

sub backup_files {

    # make sure we don't clobber any callers variables

    local @ARGV = @ARGV;
    GetOptions( \%options, keys(%opts) ) || pod2usage( -verbose => 1 );

    die("Version: $VERSION\n") if ( $options{version} );
    pod2usage( -verbose => 1 ) if ( $options{'?'}  || $options{help} );
    pod2usage( -verbose => 2 ) if ( $options{HELP} || $options{man} );

    $options{debug} ||= 0;
    $options{debug} = 8 if ( $options{debug} > 8 );

    if ( !@ARGV ) {
        pod2usage(
            -message => 'No filenames provided.',
            -verbose => 0,
        );
    }

    my $date = strftime( '%Y%m%d', localtime() );
    my $time = strftime( '%H%M%S', localtime() );

    my $username = getpwuid($EUID);

    if ( $username eq 'root' ) {
        logmsg( 2, 'Running as root so dropping username' );
        $username = '';
    }

    my $sum = find_sum();
    logmsg( 2, "Using $sum" );

    foreach my $filename (@ARGV) {
        my ( $basename, $dirname ) = fileparse($filename);

        # do this as we might mvoe this into archive or save dir in future
        my $savedir = $dirname;

        logmsg( 2, "dirname=$dirname" );
        logmsg( 2, "basename=$basename" );

        if ( !-f $filename ) {
            warn "WARNING: File $filename not found", $/;
            next;
        }

        if ( !$savedir ) {
            warn "WARNING: $savedir does not exist", $/;
            next;
        }

        # get last backup and compare to current file to prevent
        # unnecessary backups being created
        opendir( my $savedir_fh, $savedir )
            || die( "Unable to read $savedir: $!", $/ );
        my @save_files = sort
            grep( /$basename\.(?:$username\.)?\d{8}/, readdir($savedir_fh) );
        closedir($savedir_fh) || die( "Unable to close $savedir: $!", $/ );

        if ( $options{debug} > 2 ) {
            logmsg( 3, "Previous backups found:" );
            foreach my $bk (@save_files) {
                logmsg( 3, "\t$bk" );
            }
        }

        # compare the last file found with the current file
        my $last_backup = $save_files[-1];
        if ($last_backup) {
            logmsg( 1, "Found last backup as: $last_backup" );

            my $last_backup_sum = qx/$sum $last_backup/;
            chomp($last_backup_sum);
            my $current_sum = qx/$sum $filename/;
            chomp($current_sum);

            logmsg( 2, "Last backup file $sum: $last_backup_sum" );
            logmsg( 2, "Current file $sum: $current_sum" );

            if ( $last_backup_sum eq $current_sum ) {
                logmsg( 0, "No change since last backup of $filename" );
                next;
            }
        }

        my $savefilename = "$savedir$basename";
        $savefilename .= ".$username" if ($username);
        $savefilename .= ".$date";
        if ( -f $savefilename ) {
            $savefilename .= ".$time";
        }

        logmsg( 1, "Backing up to $savefilename" );

        if ( system("cp $filename $savefilename") != 0 ) {
            warn "Failed to back up $filename", $/;
            next;
        }

        logmsg( 0, "Backed up $filename to $savefilename" );
    }

    return 1;
}

=head2 logmsg($level, @message);

Output @message if $level is equal or less than $options{debug}

=cut

sub logmsg {
    my ( $level, @text ) = @_;
    print @text, $/ if ( $level <= $options{debug} );
}

=head2 $binary = find_sum();

Locate a binary to use to calculate a file checksum.  Looks first for md5sum, then sum.  Dies on failure to find either.

=cut

sub find_sum {
    return
           which('md5sum')
        || which('sum')
        || die 'Unable to locate "md5sum" or "sum"', $/;
}

=head1 AUTHOR

Duncan Ferguson, C<< <duncan_j_ferguson at yahoo.co.uk> >>

=head1 BUGS

Please report any bugs or feature requests via the web interface at 
L<https://github.com/duncs/perl-app-bk/issues>/  
I will be notified, and then you'll automatically be notified of 
progress on your bug as I make changes.

=head1 SUPPORT

You can find documentation for this module with the perldoc command.

    perldoc App::bk


You can also look for information at:

=over 4

=item * HitHUB: request tracker

L<https://github.com/duncs/perl-app-bk/issues>

=item * AnnoCPAN: Annotated CPAN documentation

L<http://annocpan.org/dist/App-bk>

=item * CPAN Ratings

L<http://cpanratings.perl.org/d/App-bk>

=item * Search CPAN

L<http://search.cpan.org/dist/App-bk/>

=back


=head1 ACKNOWLEDGEMENTS


=head1 LICENSE AND COPYRIGHT

Copyright 2011 Duncan Ferguson.

This program is free software; you can redistribute it and/or modify it
under the terms of either: the GNU General Public License as published
by the Free Software Foundation; or the Artistic License.

See http://dev.perl.org/licenses/ for more information.


=cut

1;    # End of App::bk
