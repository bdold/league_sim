package Player;

use Moose;
use namespace::autoclean;
use List::Util qw/sum/;

has league => (
    is  => 'ro',
    isa => 'League',
);

has games_played => (
    is      => 'rw',
    isa     => 'Int',
    default => 0,
);

has games_attended => (
    is      => 'rw',
    isa     => 'Int',
    default => 0,
);

has scores => (
    is      => 'rw',
    isa     => 'ArrayRef[Int]',
    default => sub { [] },
);

sub games_missed {
    my ($self) = @_;

    return 13 - $self->games_attended;
}

sub league_score {
    my ($self) = @_;

    my @sorted_scores     = sort { $b <=> $a } @{ $self->scores };
    my @top_sorted_scores = grep { $_ } (@sorted_scores[0..9]);

    return sum @top_sorted_scores;
}

# XXX: this can be tweaked.  seems like the optimal algorithm though
sub declare_or_not {
    my ($self, $game) = @_;

    return 1 if $self->league->type eq 'UNDECLARED';
    return 0 if $self->games_remaining <= 0;
    return 1 if $self->games_remaining >= $self->league->games_remaining;
    return 1 if $game->player_count >= 9;

    return 0;
}

sub games_remaining {
    my ($self) = @_;
    return 10 - $self->games_played;
}

__PACKAGE__->meta->make_immutable;
1;
