my $cgi = new CGI;
my $pjx = new CGI::Ajax( 'GetArray' => \&getarray );

#print "Content-Type: text/html; charset=utf-8\n\n";

print $pjx->build_html( $cgi, \&main );




sub main
{
	
	my $html;
	#$print "Content-Type: text/html; charset=utf-8\n\n";
	my $h = HTML::Template->new(filename => './templates/header.html');
	#print $cgi->header;
	#print $h->output;
	$html .=$h->output;
	my $m = HTML::Template->new(filename => './templates/menu.html');
	#print $cgi->header;
	#print $m->output;
	$html .=$m->output;
	my $c = HTML::Template->new(filename => './templates/content.html');
	#print $cgi->header;
	#print $c->output;
	$html .=$c->output;
	my $f = HTML::Template->new(filename => './templates/footer.html');
	#print $f->output;
	$html .=$f->output;
	$html = decode_utf8($html);
    return $html;

}