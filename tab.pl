use v5.10;

my @aminos =
  qw(ASP GLU ASN SER GLN HIS GLY THR CIT ARG b-ALA   TAU ALA TYR TRP MET VAL PHE ILE LEU ORN LYS);
say( join ',', '""', @aminos );
opendir( my $dh, '.' ) || die;
while ( readdir $dh ) {
    my ( $sample, $data_href ) = get_data_from_file($_) if /\.ars/;
    if ($sample) {
        say( join ',', $sample,
            map { $data_href->{ '"' . $_ . '"' } } @aminos );
    }
}
closedir $dh;

### sub ###

sub read_file_to_array {
    my $file     = shift;
    my $document = do {
        local $/ = undef;
        open my $fh, "<", $file
          or die "could not open $file: $!";
        <$fh>;
    };
    $document =~ s/(\012|\015\012?)/\012/g;
    my @lines = split '\n', $document;
    return @lines;
}

sub get_required_lines {
    my @all_lines = @_;
    my $result;
    my @required_lines;
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

sub get_sample_name {
    my ($sample_line) = grep { /Sample Name/ } @_;
    my $sample_name = ( split '\t', $sample_line )[1];
    return $sample_name;
}

sub get_data_from_file {
    my $file_name = shift;
    my @lines     = read_file_to_array($file_name);
    my $sample    = get_sample_name(@lines);
    my $data_href = get_required_lines(@lines);
    return ( $sample, $data_href );
}

