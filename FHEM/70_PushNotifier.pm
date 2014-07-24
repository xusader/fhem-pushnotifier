###############################################
#$Id: 70_PushNotifier.pm 2014-07-22 11:07:00 xusader
#
#	download client-app http://pushnotifier.de/apps/
#	create account http://pushnotifier.de/login/
#	get apiToken from http://gidix.de/setings/api/ and add a new app 
#	get appToken with:
#	curl -s -F apiToken="apiToken=your apiToken" -F username="your username" -F password="your password" http://a.pushnotifier.de/1/login 
#	get deviceID with:
#	curl -s -F "apiToken=your apiToken" -F "appToken=your appToken" http://a.pushnotifier.de/1/getDevices
#
#	define yourname PushNotifier apiToken appToken appname deviceID
#
#	notify example:
#	define LampON notify Lamp:on {fhem("set yourname message Your message!")}
#

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
  my ($hash, $name, $cmd, @a) = @_;
	my %sets = ('message' => 1);
	if(!defined($sets{$cmd})) {
		return "Unknown argument $cmd, choose one of " . join(" ", sort keys %sets);
	}  
    return PushNotifier_Send_Message($hash, @a);
}
#####################################
sub
PushNotifier_Send_Message#($@)
{
  my $hash = shift;
  my $msg = join(" ", @_);
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
 
    my $error_chk = $response->as_string;    

    if($error_chk =~ m/"status":"ok"/) {
	return "OK";
	}
	else 
	{
	return $error_chk; 
    }
   
}

1;
