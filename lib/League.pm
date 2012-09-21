package League;

use Moose;
use namespace::autoclean;
use Player;
use Game;
use List::Util qw/sum/;

has type => (
    is       => 'ro',
    isa      => 'Str',
    required => 1,
);

has players => (
    is         => 'ro',
    isa        => 'ArrayRef[Player]',
    lazy_build => 1,
);

sub _build_players {
    my ($self) = @_;

    return [ map { Player->new(league => $self) } 1..10 ];
}

has games => (
    is         => 'ro',
    isa        => 'ArrayRef[Game]',
    lazy_build => 1,
);

sub _build_games {
    my ($self) = @_;

    return [ map { Game->new( league => $self ) } 1..13 ];
}

sub play {
    my ($self) = @_;

    $_->play for @{ $self->games };

    return;
}

sub games_remaining {
    my ($self) = @_;

    my $played_count = grep { $_->played } @{ $self->games };

    return 13 - $played_count;
}

sub total_player_points {
    my ($self) = @_;

    return sum map { $_->league_score // 0 } @{ $self->players };
}

sub total_game_points {
    my ($self) = @_;

    return sum map { $_->score } @{ $self->games };
}

__PACKAGE__->meta->make_immutable; 1;
