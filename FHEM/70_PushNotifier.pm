###############################################
# Sample fhem module, one-level approach, controlling a single device like a
# directly attached heating regulator.
# The alternative is a two level approach, where a physical device like a CUL
# is a bridge to a large number of logical devices (like FS20 actors, S300
# sensors, etc)

package main;
use LWP::UserAgent;

sub
PushNotifier_Initialize($)
{
  my ($hash) = @_;

  $hash->{DefFn}   = "PushNotifier_Define";
  $hash->{SetFn}   = "PushNotifier_Set";

}

#####################################
sub
PushNotifier_Define($$)
{
  my ($hash, $def) = @_;
  my @args = split("[ \t]+", $def);

  my ($name, $type, $apiToken, $appToken, $app, $deviceID) = @args;
  
  $hash->{STATE} = 'Initialized';

 if(defined($apiToken) && defined($appToken)&& defined($app)&& defined($deviceID)) {
  $hash->{apiToken} = $apiToken;
  $hash->{appToken} = $appToken;
  $hash->{app} = $app;
  $hash->{deviceID} = $deviceID;
  
  return undef;
  }
}

#####################################
sub
PushNotifier_Set($@)
{
  my ($hash, $name, $msg, @args) = @_;
	my %sets = ('message' => 1);
	if(!defined($sets{$msg})) {
		return "Unknown argument $msg, choose one of " . join(" ", sort keys %sets);
	}  
    return PushNotifier_Send_Message($hash, @args);  
}
#####################################
sub
PushNotifier_Send_Message($@)
{
  my ($hash, $msg) = @_;
  my $apiToken = $hash->{apiToken};
  my $appToken = $hash->{appToken};
  my $app = $hash->{app};
  my $deviceID = $hash->{deviceID};

  my %settings = (
	'apiToken' => $apiToken,
	'appToken' => $appToken,
	'app' => $app,
	'deviceID' => $deviceID,
	'type' => 'MESSAGE',
	'content' => "$msg"
    );

    LWP::UserAgent->new()->post("http://a.pushnotifier.de/1/sendToDevice", \%settings);
    return undef;     
}

1;
