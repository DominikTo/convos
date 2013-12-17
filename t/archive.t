use Test::More;
use File::Temp qw/tempdir/;

use_ok('WebIrc::Core::Archive');
my $log_dir = tempdir(CLEANUP => 0);
ok(-d $log_dir, 'Created a log directory correctly');
my $archive = WebIrc::Core::Archive->new(log_dir => $log_dir);
isa_ok($archive, 'WebIrc::Core::Archive', 'Right class');
{
  $archive->write(
    {
      target    => '#twilight_zone',
      timestamp => 0,
      cid       => 1,
      nick      => 'me',
      host      => 'localhost',
      user      => 'ohmy',
      message   => 'Hello World',
      event     => 'message'
    }
  );
  my $file = $log_dir . '/1/#twilight_zone/1970/01/01.log';
  ok(-f $file, "Generated log file $file");
  open(my $fh, '<', $file) || die "Could not open log file: $!";
  my $line = <$fh>;
  is(
    $line,
    "01:00:00 :me!ohmy\@localhost Hello World\n",
    'Wrote log correctly'
  );
  close($fh);

};
{
  $archive->write(
    {
      target    => '#twilight_zone',
      timestamp => 100800,
      cid       => 1,
      nick      => 'me',
      host      => 'localhost',
      user      => 'ohmy',
      message   => 'Goodbye World',
      event     => 'message'
    }
  );
  $archive->write(
    {
      target    => '#twilight_zone',
      timestamp => 100860,
      cid       => 1,
      nick      => 'you',
      host      => 'otherhost',
      user      => 'ohyou',
      message   => 'Take Care!',
      event     => 'message'
    }
  );
  my $file = $log_dir . '/1/#twilight_zone/1970/01/02.log';
  ok(-f $file, "Generated log file $file");
  open(my $fh, '<', $file) || die "Could not open log file: $!";
  my $line = <$fh>;
  is(
    $line,
    "05:00:00 :me!ohmy\@localhost Goodbye World\n",
    'Wrote first line of second log correctly'
  );
  $line = <$fh>;
  is(
    $line,
    "05:01:00 :you!ohyou\@otherhost Take Care!\n",
    'Wrote second line of second log correctly'
  );
  close($fh);
}


done_testing;
