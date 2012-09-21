package Game;

use Moose;
use namespace::autoclean;
use List::Util qw/shuffle/;
use Set::Object qw/set/;
use List::Util qw/sum/;

my ($FIRST, $SECOND, $THIRD) = 0..2;

my $PAYOUT_MATRIX = [];
$PAYOUT_MATRIX->[6]  = [44, 24, 12];
$PAYOUT_MATRIX->[7]  = [50, 27, 13];
$PAYOUT_MATRIX->[8]  = [55, 30, 15];
$PAYOUT_MATRIX->[9]  = [61, 33, 16];
$PAYOUT_MATRIX->[10] = [66, 36, 18];

my @SEASON_PLAYER_COUNTS
    = ( 8,  8,  8,  8, 10, 10,  8,  7,  9,  9,  9, 10,  7,
        7,  9,  8, 10, 10, 10,  8, 10, 10,  9, 10, 10, 10,
        9,  9, 10, 10,  9,  9,  8,  9,  9,  7, 10,  7, 10,
       10, 10,  8,  8,  8,  9,  7,  9, 10,  6,  8,  8, 10 );

has league => (
    is => 'ro',
    isa => 'League',
);

has score => (
    is => 'rw',
    isa => 'Int',
);

has avg_player_count     => ( is => 'ro', isa => 'Num', default => '8.9' );
has std_dev_player_count => ( is => 'ro', isa => 'Num', default => '2'   );

has played => (
    is      => 'rw',
    isa     => 'Bool',
    default => 0,
);

has players => (
    is         => 'ro',
    isa        => 'ArrayRef[Player]',
    lazy_build => 1,
);

has player_count => (
    is         => 'ro',
    isa        => 'Int',
    lazy_build => 1,
);

sub _build_players {
    my ($self) = @_;

    my @players = shuffle @{ $self->league->players };

    return [ map { $players[$_] } 0..$self->player_count-1 ];
}

sub _build_player_count {
    my ($c) = shuffle @SEASON_PLAYER_COUNTS;
    return $c;
}

sub payout {
    my ($self, $place) = @_;

    return $PAYOUT_MATRIX->[$self->player_count]->[$place];
}

sub play {
    my ($self) = @_;

    my @undeclared;
    for my $player (@{ $self->players } ) {

        $player->games_attended( $player->games_attended+1 );

        if ($player->declare_or_not($self)) {
            $player->games_played( $player->games_played+1 );
        }
        else {
            push @undeclared, $player;
        }
    }

    my $undeclared_set = set(@undeclared);

    # pick a 1st, 2nd, 3rd
    my ($first, $second, $third) = shuffle @{ $self->players };

    my $game_score
        = sum $self->payout($FIRST),
              $self->payout($SECOND),
              $self->payout($THIRD);

    $self->score($game_score);

    # add pts to 1st, 2nd, 3rd
    push @{ $first->scores }, $self->payout($FIRST)
        if !$undeclared_set->contains($first);

    push @{ $second->scores }, $self->payout($SECOND)
        if !$undeclared_set->contains($second);

    push @{ $third->scores }, $self->payout($THIRD)
        if !$undeclared_set->contains($third);

    $self->played(1);

    return;
}

__PACKAGE__->meta->make_immutable;
1;
