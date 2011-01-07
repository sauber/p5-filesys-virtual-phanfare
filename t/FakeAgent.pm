package FakeAgent;

# Emulate responses from Phanfare using local data files.

use YAML::Syck qw(LoadFile);
use base qw(WWW::Phanfare::API);
our $AUTOLOAD;

sub AUTOLOAD {
  warn "*** FakeAgent $AUTOLOAD not handled\n";
}

sub Authenticate {
  warn "*** FakeAgent Authenticate\n";
  LoadFile 't/data/session.yaml';
}
sub GetAlbumList {
  warn "*** FakeAgent GetAlbumList\n";
  LoadFile 't/data/albumlist.yaml';
}
sub GetAlbum     {
  warn "*** FakeAgent GetAlbum\n";
  LoadFile 't/data/albuminfo.yaml';
}

# Make sure not caught by AUTOLOAD
sub DESTROY {}

1;
