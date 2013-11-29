package WWW::Tamagoya;

=head1 NAME

WWW::Tamagoya - tamagoya.co.jp menu viewer for perl.

=head1 SYNOPSIS

  use WWW::Tamagoya;

=head1 DESCRIPTION

WWW::Tamagoya is scraping library client for perl at tamagoya.co.jp

=cut

use strict;
use warnings;
use utf8;
use Carp;
use Encode;
use Try::Tiny;
use URI::Escape;
use Web::Scraper;
use WWW::Mechanize;
use Class::Accessor::Lite(
    new => 1,
);

=head1 PACKAGE GLOBAL VARIABLE

=over

=item B<VERSION>

version.

=item B<BASE_URL>

tamagoya.co.jp top url.

=item B<MENU_PATH>

weekly menu path.

=back

=cut

our $VERSION   = '0.01';
our $BASE_URL  = q{http://www.tamagoya.co.jp/};
our $MENU_PATH = q{menu.html};

=head1 CONSTRUCTOR AND STARTUP

=head2 new

Creates and returns a new WWW::Tamagoya object.

my $tamago = WWW::Tamagoya->new();

=head1 Accessor

=over

=item B<mech>

WWW::Mechanize object.

=back

=cut

sub mech {
    my $self = shift;
    $self->{__mech} ||= WWW::Mechanize->new(
        agent => 'Mozilla/5.0 (Windows NT 6.1; rv:19.0) Gecko/20100101 Firefox/19.0',
        cookie_jar => {},
    );
}

=head1 METHODS

=head2 menu_list

get menu list..

my $list = $tamago->menu_list;
for my $menu (@$list){
  print "$menu->{date}: $log->{menu_main}"
}

=cut

sub menu_list {
    my $self = shift;
    my $res = $self->mech->get($BASE_URL . $MENU_PATH);
    return $self->_parse($res->decoded_content());
}

=head1 PRIVATE METHODS

=over

=item b<_parse>

scrape at the menu.

=cut

sub _parse {
    my $self = shift;
    my $html = shift;
    my $menu_list = [];
    my $now = DateTime->now( time_zone  => 'Asia/Taipei', );
    my $date = clone $now;
    my (undef,undef,undef,$day,$month,$year) = localtime(time);
    my $scraper = scraper {
        process '//div[@id="latestnews_txt"]/div[@class="menu_list"]', 'data[]' => scraper {
            process '//ul/li[@class="menu_maindish"]', 'menu_main'  => 'TEXT';
            process '//ul/li[@class="menu_arrow"]',    'menu_sub[]' => 'TEXT';
            process '//p[@class="menu_calorie"]',      'kcal_solt'  => 'TEXT';
        };
        process '//div[@id="latestnews_txt"]/div[@class="menu_title"]', 'days[]'  => scraper {
            process '//p[@class="menutitle_date"]', day => 'TEXT';
        };
        result 'days', 'data';
    };
    my $result = $scraper->scrape($html);
    for my $idx ( 0..$#{$result->{data}} ) {
        my $menu_data = $result->{data}->[$idx];
        my $menu_day  = $result->{days}->[$idx]->{day};
        my $kcal_solt = $menu_data->{kcal_solt};
        $menu_day =~ s{(\d+).*}{$1};
        my $row = {
            day       => $menu_day,
            menu_main => $menu_data->{menu_main},
            menu_sub  => join(',', @{$menu_data->{menu_sub}}),
        };
        if($kcal_solt =~ m{.*?([0-9]+?kcal)／.*?([0-9\.]+?g)}){
            $row->{kcal} = $1;
            $row->{solt} = $2;
        }
        push @$menu_list, $row;
    }
    return $menu_list;
}

1;

__END__

=back

=head1 AUTHOR

likkradyus E<lt>perl {at} li.que.jpE<gt>

=head1 SEE ALSO

=head1 LICENSE

This library is free software; you can redistribute it and/or modify
it under the same terms as Perl itself.

=cut
