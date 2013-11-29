#!/user/bin/env perl
use strict;
use warnings;
use utf8;
use Encode;
use HTTP::Date;
use WWW::Tamagoya;
use YAML;

my $menu = WWW::Tamagoya->new()->menu_list;
warn YAML::Dump $menu;
