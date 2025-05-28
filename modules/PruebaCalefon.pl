#!/usr/bin/perl
use CGI;
use Data::Dumper;
use LWP::UserAgent;
use lib "./modules";
use Calefon;


###### Entrada de lore
      #my @h_Mes= (181.15,158,77,156.77,122.22,104.32,94.21,110.57,134.15,155.97,164.30,173.21,183.65);
     # my @consumoMensual=(4958,3962,4743,4448,5278,5439,7474,5685,4609,7836,369,4239);
      
     #my  @temperaturaMedia= ();
      my $reporte= 1;
      my $ley= 0;
      my $costoEquipo= 10000;
      my $costoInstal= 23000; 
      my $tipoUsuario= 0;
      my $cobres= 0;  #si es cero no hace la instalacion en san antonio de los cobres
      my $longitud= "24.9";
      my $altitud= "1400";
      my $consumo="230,220,200,160,130,120" ;
     ###agregar 
      my $latitud= "-24.79";
      my $longitud= -65.42 ;
      my $tipoColector=1 ;#tipo de instalación tubos evacuados es 2
      my $Tmedia= 30;
      my $cantPersonas= 4;
#####   
		my $h_Mes= "184.53,162.83,153.86,122.05,103.53,93.46,109.87,134.79,156.03,163.92,172.58,189.75";
		my $tempMedia= "23,22,20,16,13,12,13,14,16,19,21,22";
		my $data1= "$reporte,$ley,$costoEquipo,$costoInstal,$tipoUsuario,$cobres,$longitud,$altitud,";
		my $dataNatural= $data1."$latitud,$cantPersonas,$tipoColector,$h_Mes,$tempMedia,$consumo"; 
		 my $reporte= 1;
##Natural
	
my $data= "$latitud,$longitud,$altitud,$cantPersonas,$tipoColector,$reporte,184.53,162.83,153.86,122.05,103.53,93.46,109.87,134.79,156.03,163.92,172.58,189.75,23,22,20,16,13,12,13,14,16,19,21,22,5";
    #latitud,$cantPersonas,$tipoColector,@RadYtemp
		my $consumoNatu= 168,217,139,331,228,250;

		my $dataNatural= "$latitud,$longitud,$altitud,$cantPersonas,$reporte,$tipoColector,$h_Mes,$tempMedia,168,217,139,331,228,250";

###Electricidad
my $consumoElect="230,220,200,160,130,120,230,220,200,160,130,120" ;
my $dataElect= "$latitud,$longitud,$altitud,$cantPersonas,$tipoColector,$reporte,$h_Mes,$tempMedia,$consumoElect"; 
		 
 print Dumper Calefon::calculaElectricidad($dataElect);
#rint Dumper Calefon::calculaNatural($dataNatural);
#print Dumper Calefon::calculaEnvasado($data);

#my $dataSinInst= "$latitud,$longitud,$altitud,$cantPersonas,$tipoColector,$reporte,184.53,162.83,153.86,122.05,103.53,93.46,109.87,134.79,156.03,163.92,172.58,189.75,23,22,20,16,13,12,13,14,16,19,21,22";
my $dataSinInst= "$latitud,$longitud,$altitud,$cantPersonas,$tipoColector,$reporte,$h_Mes,$tempMedia";

 print Dumper Calefon::calculaSinInstalacion($dataSinInst);
