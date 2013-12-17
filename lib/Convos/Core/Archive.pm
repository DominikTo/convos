package Convos::Core::Archive;

use Mojo::Home;
use Carp qw/croak/;

use Convos::Core::Util qw/format_time/;

use File::Path qw/make_path/;

=head1 NAME

Convos::Core::Archive - Backend archive

=head1 SYNOPSIS

TODO

=cut

use Mojo::Base -base;
use Mojo::UserAgent;

=head1 ATTRIBUTES

=head2 log_dir

Path to write logs in

=cut

has 'log_dir' => sub {
  Mojo::Home->new->detect('Convos')->rel_dir('irc_logs');
};

=head2 es_url

Mojo::URL to Elasticsearch

=cut

has 'es_url' => sub {
  my $self=shift;
  my $url=Mojo::URL->new('http://localhost:9200/');
  my $res=$self->ua->get($url)->success;
  return $res ? $url : undef;
};

=head2 ua

User Agent for ES communication

=cut

has ua => sub { Mojo::UserAgent->new };


=head2 paths

Current log path. Automatically generated through irc message.

=cut

has paths => sub { +{} };

=head1 METHODS


=head2 search

  TODO = $self->search(TODO);

=cut

sub search {
  my $self = shift;
}

=head2 write

  $self->write($data)

Write a log message from a core connection's message.

=cut

sub write {
  my ($self, $message) = @_;
  my $ts   = $message->{timestamp};
  if($self->es_url) {
    $self->ua->put($self->es_url->path('/wirc/messages') , json => $message);
  }
  my $path = sprintf('%s/%s/%s/%s',
    $self->log_dir, $message->{server}, $message->{target},
    format_time($ts, '/%Y/%m/'));
  make_path($path) unless $self->paths->{$path}++;
  $path .= format_time($ts, '%d.log');
  croak qq{Can't open log file "$path": $!}
    unless open my $handle, '>>', $path;
    $message->{nick} //= '[nick_missing]';
  print($handle sprintf(
      "%s :%s!%s@%s %s\n",
      format_time($ts, '%H:%M:%S'),
      @{$message}{qw/nick user host message/}
    )
  );
  close $handle;
}

=head1 COPYRIGHT

See L<Convos>.

=head1 AUTHOR

Jan Henning Thorsen

Marcus Ramberg

=cut

1;
