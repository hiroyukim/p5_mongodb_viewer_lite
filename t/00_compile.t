use strict;
use warnings;
use utf8;
use Test::More;

use_ok $_ for qw(
    MongoDBViewrLite
    MongoDBViewrLite::Web
    MongoDBViewrLite::Web::ViewFunctions
    MongoDBViewrLite::Web::Dispatcher
);

done_testing;
