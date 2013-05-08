package MongoDBViewrLite::Web::Dispatcher;
use strict;
use warnings;
use utf8;
use Data::Page;
use Tie::IxHash;
use Amon2::Web::Dispatcher::Lite;

any '/' => sub {
    my ($c) = @_;
    return $c->redirect('/mongodb/');
};


any '/mongodb/' => sub {
    my ($c) = @_;

    my @database_info_list;
    for my $database_name ( $c->mongodb->database_names ) {
        my @collections   = grep { not $_ =~ /\$_id_/ } $c->mongodb->get_database( $database_name )->collection_names;
        push @database_info_list,{
            database_name => $database_name,
            collection_info_list => [
                map +{
                    collection_name  => $_,
                    collection_count => $c->mongodb->get_database( $database_name )->get_collection($_)->find()->count(),
                }, @collections
            ],
        };
    }

    return $c->render('/mongodb/index.tt',{
        database_info_list => [@database_info_list],
        build_info   => $c->mongodb->get_database('admin')->get_collection('$cmd')->find_one(Tie::IxHash->new('buildinfo' => 1)),
        serverStatus => $c->mongodb->get_database('admin')->get_collection('$cmd')->find_one(Tie::IxHash->new('serverStatus' => 1)),
    });
};

any '/mongodb/database/collection/document/list' => sub {
    my ($c) = @_;

    my $database_name   = $c->req->param('database_name')   or return $c->redirect('/');
    my $collection_name = $c->req->param('collection_name') or return $c->redirect('/');

    my $page            = $c->req->param('page') || 1;
    my $limit           = 10;

    unless( grep { $database_name eq $_ } $c->mongodb->database_names ) {
        return $c->redirect('/');
    }

    unless( grep { $collection_name eq $_ } $c->mongodb->get_database($database_name)->collection_names ) {
        return $c->redirect('/');
    }
    my $collection = $c->mongodb->get_database($database_name)->get_collection($collection_name);

    my $document_count = $collection->find()->count();
    my $document_list = $collection->find()->limit($limit)->sort({ '$natural' => -1 })->skip(($page - 1) * $limit);

    return $c->render('/mongodb/database/collection/document/list.tt',{
        document_count  => $document_count,
        document_list   => $document_list,
        pager           => Data::Page->new(
            $count, #total_entries
            $limit, #entries_per_page
            $page, #current_page
        ),
    });
};

1;


1;
