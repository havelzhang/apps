#---------------------------------------------------------------------
# utility to print data structure to a readable format
#---------------------------------------------------------------------
package pretty_print;

$output;
$level = -1;

sub pretty_print {
    my $var;
	$output = '';
	$level = -1;
    foreach $var (@_) {
		if (!defined ($var)){
			$output .= "Empty\n";
			next;
		}
        if (ref ($var)) {
			print_ref($var);
        } else {
            print_scalar($var);
        }
    }
	$output;
}

sub print_scalar {
    ++$level;
    print_indented ($_[0]);
    --$level;
}

sub print_ref {
    my $r = $_[0];
#    if (exists ($already_seen{$r})) {
#        print_indented ("$r (Seen earlier)");
#        return;
#    } else {
#        $already_seen{$r}=1;
#    }
    my $ref_type = ref($r);
    if ($ref_type eq "ARRAY") {
        print_array($r);
    } elsif ($ref_type eq "SCALAR") {
        $output .= "Ref -> $r";
        print_scalar($$r);
    } elsif ($ref_type eq "HASH") {
        print_hash($r);
    } elsif ($ref_type eq "REF") {
        ++$level;
        print_indented("Ref -> ($r)");
        print_ref($$r);
        --$level;
    } else {
        print_indented ("$ref_type (not supported)");
    }
}

sub print_array {
    my ($r_array) = @_;
    ++$level;
#print_indented ("[ # $r_array");
    print_indented ("[");
    foreach $var (@$r_array) {
        if (ref ($var)) {
            print_ref($var);
        } else {
            print_scalar($var);
        }
    }
    print_indented ("]");
    --$level;
}

sub print_hash {
    my($r_hash) = @_;
    my($key, $val);
    ++$level; 
#print_indented ("{ # $r_hash");
    print_indented ("{ ");
    while (($key, $val) = each %$r_hash) {
        $val = ($val ? $val : '""');
        ++$level;
        if (ref ($val)) {
            print_indented ("$key => ");
            print_ref($val);
        } else {
			if ($key =~ m/password/i){
            	print_indented ("$key => **********");
			}else{
            	print_indented ("$key => $val");
			}
        }
        --$level;
    }
    print_indented ("}");
    --$level;
}

sub print_indented {
    $spaces = ":  " x $level;
    $output .= "${spaces}$_[0]\n";
}



1;
