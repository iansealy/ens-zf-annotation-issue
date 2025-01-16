#!/usr/bin/env perl

use warnings;
use strict;
use autodie;

use Carp;
use Getopt::Long;
use Pod::Usage;

use Readonly;
use Try::Tiny;
use Bio::EnsEMBL::Registry;

our $VERSION = '1.00';

# Constants
Readonly our $ENSEMBL_SPECIES => 'danio_rerio';

# Default options
my $ensembl_dbhost = 'ensembldb.ensembl.org';
my $ensembl_dbport;
my $ensembl_dbuser = 'anonymous';
my $ensembl_dbpass;
my $slice_regexp;
my ( $debug, $help, $man );

# Get and check command line options
get_and_check_options();

# Connnect to Ensembl database
Bio::EnsEMBL::Registry->load_registry_from_db(
    -host => $ensembl_dbhost,
    -port => $ensembl_dbport,
    -user => $ensembl_dbuser,
    -pass => $ensembl_dbpass,
);

# Get genebuild version
my $genebuild_version = Bio::EnsEMBL::ApiVersion::software_version();
warn 'Genebuild version: ', $genebuild_version, "\n" if $debug;

# Get Ensembl adaptors
my $sa =
  Bio::EnsEMBL::Registry->get_adaptor( $ENSEMBL_SPECIES, 'core', 'Slice' );

# Ensure database connection isn't lost
Bio::EnsEMBL::Registry->set_reconnect_when_lost();

# Get all slices
my $slices = $sa->fetch_all('toplevel');
warn scalar @{$slices}, " slices\n" if $debug;

foreach my $slice ( @{$slices} ) {
    next
      if defined $slice_regexp
      && $slice->seq_region_name !~ m/$slice_regexp/xms;
    warn 'Slice: ', $slice->name, "\n" if $debug;

    # Get all genes
    my $genes = $slice->get_all_Genes( undef, 'core' );
    warn q{ }, scalar @{$genes}, " genes\n" if $debug;
    foreach my $gene ( @{$genes} ) {
        warn ' Gene: ', $gene->stable_id, "\n" if $debug;

        # Get source of gene's name and description
        my $source = $gene->description || q{-};
        $source =~ s/.*Source://xms;
        $source =~ s/;.*//xms;

        # Count and list the annotated GO terms, ZFIN IDs and Reactome pathways
        my $links = $gene->get_all_DBLinks();
        my ( %go, %zfin_id, %reactome );
        foreach my $link ( @{$links} ) {
            if ( $link->dbname eq 'ZFIN_ID' ) {
                $zfin_id{ $link->primary_id } = 1;
            }
            elsif ( $link->dbname eq 'GO' ) {
                $go{ $link->primary_id } = 1;
            }
            elsif ( $link->dbname eq 'Reactome' ) {
                $reactome{ $link->primary_id } = 1;
            }
        }
        my $zfin_id_count  = scalar keys %zfin_id;
        my $zfin_id        = ( join q{,}, sort keys %zfin_id ) || q{-};
        my $go_count       = scalar keys %go;
        my $go             = ( join q{,}, sort keys %go ) || q{-};
        my $reactome_count = scalar keys %reactome;
        my $reactome       = ( join q{,}, sort keys %reactome ) || q{-};

        # Output summary
        print join "\t", $genebuild_version, $gene->stable_id, $source,
          $gene->biotype, ( $gene->external_name || q{-} ),
          ( $gene->description || q{-} ), $zfin_id_count, $zfin_id, $go_count,
          $go, $reactome_count, $reactome;
        print "\n";
    }
}

# Get and check command line options
sub get_and_check_options {

    # Get options
    GetOptions(
        'ensembl_dbhost=s' => \$ensembl_dbhost,
        'ensembl_dbport=i' => \$ensembl_dbport,
        'ensembl_dbuser=s' => \$ensembl_dbuser,
        'ensembl_dbpass=s' => \$ensembl_dbpass,
        'slice_regexp=s'   => \$slice_regexp,
        'debug'            => \$debug,
        'help'             => \$help,
        'man'              => \$man,
    ) or pod2usage(2);

    # Documentation
    if ($help) {
        pod2usage(1);
    }
    elsif ($man) {
        pod2usage( -verbose => 2 );
    }

    return;
}

__END__
=pod

=encoding UTF-8

=for stopwords Ensembl Sealy

=head1 NAME

dump_annotation.pl

Get annotation for each Ensembl gene

=head1 VERSION

version 1.00

=head1 DESCRIPTION

This script dumps Ensembl gene annotation.

=head1 EXAMPLES

    perl -Iensembl-110/modules dump_annotation.pl

    perl -Iensembl-110/modules dump_annotation.pl --slice_regexp '^1$'

=head1 USAGE

    dump_annotation.pl
        [--ensembl_dbhost host]
        [--ensembl_dbport port]
        [--ensembl_dbuser username]
        [--ensembl_dbpass password]
        [--slice_regexp regexp]
        [--debug]
        [--help]
        [--man]

=head1 OPTIONS

=over 8

=item B<--ensembl_dbhost HOST>

Ensembl MySQL database host.

=item B<--ensembl_dbport PORT>

Ensembl MySQL database port.

=item B<--ensembl_dbuser USERNAME>

Ensembl MySQL database username.

=item B<--ensembl_dbpass PASSWORD>

Ensembl MySQL database password.

=item B<--slice_regexp REGEXP>

Regular expression for limiting slices.

=item B<--debug>

Print debugging information.

=item B<--help>

Print a brief help message and exit.

=item B<--man>

Print this script's manual page and exit.

=back

=head1 DEPENDENCIES

Ensembl Perl API - http://www.ensembl.org/info/docs/api/

=head1 AUTHOR

=over 4

=item *

Ian Sealy <i.sealy@qmul.ac.uk>

=back

=head1 LICENSE AND COPYRIGHT

This software is Copyright (c) 2025 by Ian Sealy.

This is free software, licensed under:

  The GNU General Public License, Version 3, June 2007

=cut
