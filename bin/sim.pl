use strict;
use warnings;
use v5.10;
use List::Util qw/sum/;

use League;

sub sim {
    my ($type, $league_count) = @_;

    $league_count //= 1000;

    my $grouped_scores = {};

    for (1..$league_count) {
        my $league = League->new(type => $type);
        $league->play;

        for my $player (@{ $league->players }) {
            push @{ $grouped_scores->{ $player->games_missed } },
                 $player->league_score;
        }
    }

    my $zero_miss_score = avg($grouped_scores->{0});

    say "$type (league_count = $league_count)";

    say join ',', qw/missed player_count average_score
                    missing_points %_missing_pts/;

    for my $missed (sort { $a <=> $b } keys %{ $grouped_scores }) {

        my $player_count = @{ $grouped_scores->{$missed} };
        my $avg_score    = avg($grouped_scores->{$missed});
        my $pts_missed   = $missed && $avg_score 
                         ? ($zero_miss_score - $avg_score) / $missed
                         : 0;
        my $pct_missed   = ($pts_missed / $zero_miss_score) * 100;

        say join ',', $missed, $player_count, $avg_score,
                      fmt($pts_missed), fmt($pct_missed);
    }

    say '';
}

sub fmt {
    my ($n) = @_;
    return sprintf '%.2f', $n;
}

sub avg {
    my ($a) = @_;

    $a = [ grep { defined $_ } @{$a} ];

    return undef if !defined $a || !@{ $a };

    return sprintf '%d', sum(@$a) / scalar(@$a);
}

MAIN: {
    my $league_count = $ARGV[0];

    sim('DECLARED', $league_count);
    sim('UNDECLARED', $league_count);
}
