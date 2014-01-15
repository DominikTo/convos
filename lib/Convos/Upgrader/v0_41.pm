package Convos::Upgrader::v0_41;

=head1 NAME

Convos::Upgrader::v0_41 - Upgrade instructions to version 0.4001

=head1 DESCRIPTION

This step will move config options into the database.

=cut

use Mojo::Base 'Convos::Upgrader';

=head1 METHODS

=head2 run

Called by L<Convos::Upgrader>.

=cut

sub run {
  my ($self, $cb) = @_;
  my $config = $self->_read_config;

  Mojo::IOLoop->delay(
    sub {
      my ($delay) = @_;
      $self->redis->smembers(users => $delay->begin);
    },
    sub {
      my ($delay, $users) = @_;

      if (@$users == 1) {
        $self->redis->hset("user:$users->[0]", admin => 1, $delay->begin);
      }
      elsif (@$users > 1) {

        # Log that we failed to set "admin" for a given user
      }

      $self->redis->mset(
        'convos:name'        => $config->{name}        || 'Convos',
        'convos:invite_code' => $config->{invite_code} || '',
        $delay->begin,
      );
    },
    sub {
      my ($delay, @set) = @_;
      $self->$cb('');
    },
  );
}

sub _read_config {
  my $self = shift;

  # TODO: No idea how to get config from here
}

=head1 AUTHOR

Jan Henning Thorsen - C<jhthorsen@cpan.org>

=cut

1;
