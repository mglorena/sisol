#!/usr/local/ActivePerl-5.16/bin/perl -w

use Reporte;

  my $latitud= -68.0850 ;
  my $longitud= -24.99;
  my $altitud= 1400;
  my $capacidad= "1";
  my $inclinacion="30";
  my $tipoMontaje= "3";
  my $eficiencia= "95";
  my $perdida= "0.1";
  my @consumo= (123,234,234,135,234,567,456,342,435,543,654,231);
  my @generacion= (102,134,134,135,134,167,156,142,135,143,154,131);
  my $data= "$latitud,$longitud,1400,$altitud,$capacidad,$inclinacion,$tipoMontaje,$eficiencia,$perdida,1,"."184.53,162.83,153.86,122.05,103.53,93.46,109.87,134.79,156.03,163.92,172.58,189.75,168,168,139,328,148,217,331,250,228,197,174,169"; 
	
   Reporte::creaReporte($data);
