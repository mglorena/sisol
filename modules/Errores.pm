#!/usr/bin/perl
#
# @File Errores.pm
# @Author Lorena garcia
# @Created Abril 09 de 2018 6:44:24 PM
#

#Modulo que inclina la radiacion recibida
# Duffie and Beckman 104, capitulo 2.19: Average Radiation on Sloped Surfaces: Isotropi Sky edicion Judith 
# Dia caracteristico
# parametros de entrada: latitud, la radiacion mensual dividida por la cantidad de dias, día juliano, beta inclinación del panel
# azimut considerado 180, es decir mirando al norte
#package Radiacion;


package Errores;


use Data::Dumper;
use CGI;
# use HTML::ParseBrowser;
# use CGI qw(:standard);
# use CGI::Carp qw(warningsToBrowser fatalsToBrowser);
# use Email::Send;
# use Email::Send::Gmail;
# use Email::Simple::Creator;

# sub getDataBrowser(){
#   my $uastring = @_;
#   #'Mozilla/4.0 (compatible; MSIE 5.0; Windows 98) Opera 6.0  [fr]';

#   my $ua = HTML::ParseBrowser->new($uastring);
#   my @res =($ua->name,$ua->v,$ua->os,$ua->language);
#   return @res;

# }
#   # Opera 6 on Windows 98, French

# sub SendJsErrorMessage(){
#      my ($ex, $pageName, $object) = @_;
#      if (!defined $ex) { $ex = 'Error mensaje - testing';}

#      my @browser = getBrowser($ENV{HTTP_USER_AGENT});
#      my $body = "<b>Error Report - SendJsErrorMessage</b><br/>";
#      $body .="<br/><b>Method :</b>" . $pageName;
#      $body .="<br/><br/><b>Detail</b><br/>" . $ex;
#      $body .="<br/><br/><b>Browser Info</b><br/>";
#      $body .="<br/><b>Browser:</b>" . @browser[0]. "<br/>";
#      $body .="<b>Browser Version:</b>" . @browser[1]. "<br/>";
#      my $exporte = Dumper $object;
#      $body .="<br/>" . $exporte;
#      $body .="<br/>SERVER:" . $ENV{HTTP_REFERER};
#      $body .="<br/>REMOTE HOST:" . $ENV{REMOTE_ADDR};


#    # $mailer = new TapeMailer();
#    # $mailer->From = "errores@obras.unsa.edu.ar";
#    # $mailer->FromName = "Lorena García";
#    # $mailer->Subject = 'obras.unsa.edu.ar - Error Report' . " - HOST:" . $_SERVER['SERVER_ADDR'];
#    # $mailer->Host = 'localhost';
#    # $mailer->Mailer = 'smtp';
#    # $mailer->Body = $body;
#    # $mailer->IsHTML(true);
#    # $mailer->AddAddress('infotape@obras.unsa.edu.ar', 'Tape Errores');
#    # $mailer->Host = 'obras.unsa.edu.ar';
#    # $mailer->Port = 25;
#    # $mailer->Username = 'infotape';
#    # $mailer->Password = 'info';
#    # return $mailer->Send();

#    my $email = Email::Simple->create(
#       header => [
#       From    => 'mglorena@gmail.com',
#       To      => 'nilsamsarmiento@gmail.com',
#       Subject => 'Server down',
#       ],
#       body => 'The server is down. Start panicing.',
#       );

#    my $sender = Email::Send->new(
#       {   mailer      => 'Gmail',
#       mailer_args => [username => 'mglorena@gmail.com', password => 'XXX', ]
#       }
#   );
#    eval { $sender->send($email) };
#   # die "Error sending email: $@" if $@;
# }


1;
