#!/usr/bin/perl -w

use XMLRPC::Lite;
use Data::Dumper;
use WordPress::XMLRPC;

$username="ruzickap";
$password="password";
$url="https://linux.xvx.cz/xmlrpc.php";
#$blogid=1; # doesn't matter (except blogfarm)

$o = WordPress::XMLRPC->new({
  username => $username,
  password => $password,
  proxy => $url,
});

$o->server or die( sprintf 'could not connect with %s:%s to %s', $self->username, $self->password, $self->proxy );

$res = $o->getRecentPosts(100);

#print Dumper $res;
#print \$res;

if ( not -d "posts" ) { 
  print "Creating \"posts\" directory...\n";
  mkdir "posts";
}

foreach (@{$res}){
  $text = $_->{'description'};
  if ( not $_->{'mt_text_more'} eq "" ) {
    $text .= "<!--more-->" . $_->{'mt_text_more'};
  }
  $title = $_->{'title'};
  print "$title\n";
  $title =~ s/\//-/;
  open (FILE,"> posts/$_->{'dateCreated'}-$title");
  $text =~ s/\[cc lang="(bash|php|email|lua|perl|text)"\s*\]\n/<pre><code class="$1">/g;
  $text =~ s/\[cc lang="bash"\]/<pre><code class="bash">/g;
  $text =~ s/\[\/cc\]/<\/code><\/pre>/g;
  $text =~ s/h2>/h3>/g;
  $text =~ s/<br \/>//g;
  print FILE $text;
  close(FILE);
}
