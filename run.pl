use v5.10;
use strict;
use warnings;

my @aminos =
  qw(ASP GLU ASN SER GLN HIS GLY THR CIT ARG b-ALA TAU ALA TYR TRP MET VAL PHE ILE LEU ORN LYS);

# the header
say( join ',', '""', @aminos );

opendir( my $dh, '.' ) || die;

while ( readdir $dh ) {
    my ( $name, $data ) = get_data_from_file($_) if /\.ars/;
    if ($name) {

        # the data rows
        say( join ',', $name, map { $data->{ '"' . $_ . '"' } } @aminos );
    }
}
closedir $dh;

sub read_file_to_array {
    my $file     = shift;
    my $document = do {
        local $/ = undef;
        # crlf does not work
        open my $fh, "<:crlf", $file
          or die "could not open $file: $!";
        <$fh>;
    };

    # annoying line feed between windows and linux
     $document =~ s/(\012|\015\012?)/\n/g;
    my @lines = split '\n', $document;
    return @lines;
}

sub get_sample_name {
    my ($sample_line) = grep { /Sample Name/ } @_;
    my $sample_name = ( split '\t', $sample_line )[1];
    return $sample_name;
}

sub get_sample_data {
    my @all_lines = @_;
    my $result;
    my @required_lines;

    # use a boolean to indicate the start and end
    my $process_line = 0;
    for my $line (@all_lines) {
        $process_line = 1 if $line =~ /"Amount \(nmol\/ml\)"/;
        $process_line = 0 if $line =~ /Page/;
        if ( $process_line and $line !~ /Amount/ ) {
            my ( $amino, $amount ) = ( split '\t', $line )[ 1, 5 ];
            $result->{$amino} = $amount;
        }
    }
    return $result;
}

sub get_data_from_file {
    my $file_name = shift;
    my @lines     = read_file_to_array($file_name);
    my $name      = get_sample_name(@lines);
    my $data      = get_sample_data(@lines);
    return ( $name, $data );
}

