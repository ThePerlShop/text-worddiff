#!perl -w

# $Id: pod.t 977 2004-12-17 17:30:37Z theory $

use strict;
use Test::More;
eval "use Test::Pod 1.20";
plan skip_all => "Test::Pod 1.20 required for testing POD" if $@;
all_pod_files_ok();
