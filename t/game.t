use strict;
use warnings;
use v5.10;
use Test::More;
use List::MoreUtils qw/all/;
use List::Util qw/sum/;
use Player;
use Set::Object qw/set/;

use League;
use Game;

{
    my $league = League->new(type => 'UNDECLARED');
    my $game   = Game->new( league => $league );

    isa_ok $game, 'Game';

    ok $game->player_count >= 6,  'at least 6 players';
    ok $game->player_count <= 10, 'at most 10 players';

    ok all(sub { $_->games_played == 0 }, @{ $league->players }),
        'all league players have yet to play';

    $game->play;

    ok all(sub { $_->games_played == 1 }, @{ $game->players }),
        'all game players have yet to play';

    my $players  = set(@{ $league->players });
    my $did_play = set(@{ $game->players });
    my $did_not_play = $players - $did_play;

    ok all(sub { $_->games_played == 0 }, @{ $did_not_play }),
        'all game players have yet to play';
}

{
    my $league = League->new(type => 'UNDECLARED');
    my $game   = Game->new( league => $league, player_count => 9 );

    my ($FIRST, $SECOND, $THIRD) = 0..2;

    is $game->payout($FIRST),  61, 'first place payout';
    is $game->payout($SECOND), 33, 'second place payout';
    is $game->payout($THIRD),  16, 'third place payout';

}

{
    my %exp_totals = ( 6 => 80, 7 => 90, 8 => 100, 9 => 110, 10 => 120 );

    for (6..10) {
        my $league = League->new((type => 'UNDECLARED'), games => []);
        my $game   = Game->new( league => $league, player_count => $_ );
        $game->play;

        my $total = sum grep { $_ } map { $_->league_score } @{ $game->players };

        is $total, $exp_totals{$_}, 'game score total';
    }

}

done_testing;
