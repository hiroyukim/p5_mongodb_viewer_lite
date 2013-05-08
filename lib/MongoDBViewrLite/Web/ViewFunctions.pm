package MongoDBViewrLite::Web::ViewFunctions;
use strict;
use warnings;
use utf8;
use parent qw(Exporter);
use Module::Functions;
use Text::Xslate::Util;
use File::Spec;

our @EXPORT = get_public_functions();

sub commify {
    local $_  = shift;
    1 while s/((?:\A|[^.0-9])[-+]?\d+)(\d{3})/$1,$2/s;
    return $_;
}

sub c { Amon2->context() }
sub uri_with { Amon2->context()->req->uri_with(@_) }
sub uri_for { Amon2->context()->uri_for(@_) }
sub create_table_form_ref_data {
    my ($data) = @_;

    if( ref($data) eq 'ARRAY' ) {
        my $view;
        $view .= '<table>';
        $view .= '<tr>';
        for my $row ( @{$data} ) {
            $view .= '<td>';
            $view .= create_table_form_ref_data($row);
            $view .= '</td>';
        }
        $view .= '</tr>';
        $view .= '</table>';
        return $view;
    }
    elsif( ref($data) eq 'HASH' ) {
        my $view;
        $view .= '<table>';
        for my $data_key ( sort keys %{$data} ) {
            $view .= '<tr>';
            $view .= '<th>' . $data_key . '</th>';
            $view .= '<td>';
            $view .= create_table_form_ref_data($data->{$data_key});
            $view .= '</td>';
            $view .= '</tr>';
        }
        $view .= '</table>';
        return $view;

    }
    else {
        return Text::Xslate::Util::html_escape($data);
    }
}

{
    my %static_file_cache;
    sub static_file {
        my $fname = shift;
        my $c = Amon2->context;
        if (not exists $static_file_cache{$fname}) {
            my $fullpath = File::Spec->catfile($c->base_dir(), $fname);
            $static_file_cache{$fname} = (stat $fullpath)[9];
        }
        return $c->uri_for(
            $fname, {
                't' => $static_file_cache{$fname} || 0
            }
        );
    }
}

1;
