package Fotovoltaico;
use Switch;
use Math::Trig;
use Data::Dumper;
use Reporte;


sub calculaEnergia{
      my $datos = $_[0];     

      my ($latitud,$longitud,$altitud,$conexion,$modelo,$PgfvAux,$beta,$eficiencia,$perdida,$reporte,$tipoUsuario,@radYcons)= split(/,/,$datos);
      my @h_Mes;
      for (my $i=0; $i<=11;$i++){

           push @h_Mes, $radYcons[$i];
      }
      for (my $i=12; $i<=23;$i++){
             push @consumoMensual, $radYcons[$i];
      }
      
     # $modelo= int($modelo);
      #$modelo+=0;

      my @cantDias =(31,28,31,30,31,30,31,31,30,31,30,31);
      my $albedo= 0.25;
      my $mesEnergia;
      $eficiencia= $eficiencia/100;
      $perdida= $perdida /100;
      $perdidaInversor= (1- $eficiencia) + $perdida;

      for (my $i=0; $i<=11;$i++) {
       @h_Mes[$i]=@h_Mes[$i]/ @cantDias[$i];
      };
     


       for (my $i=1; $i < 366; $i++) {
       
       

             switch ($i){
             	case [0..31] {
             				$mes=0;
             				
             			
             				$Htinclinada=def_inclina($latitud,$h_Mes[$mes], $beta, $i,$albedo);
             			
             				
             				push(@{$mesEnergia->{$mes}},def_Eac($perdidaInversor,$longitud,$modelo,$mes,$PgfvAux,$Htinclinada));
             			
             				}

                                    
             	
             	case [32..59] {
             				$mes=1;
             				$Htinclinada=def_inclina($latitud,$h_Mes[$mes], $beta, $i,$albedo);
                                    push(@{$mesEnergia->{$mes}},def_Eac($perdidaInversor,$longitud,$modelo,$mes,$PgfvAux,$Htinclinada));
                                     
                                    
                              }

             	case [59..90] {
             				$mes=2;
             				
                                    $Htinclinada=def_inclina($latitud,$h_Mes[$mes], $beta, $i,$albedo);
                                    push(@{$mesEnergia->{$mes}},def_Eac($perdidaInversor,$longitud,$modelo,$mes,$PgfvAux,$Htinclinada));
                                     
             	}

      	       	case [91..120] {
             				$mes=3;
             				$Htinclinada=def_inclina($latitud,$h_Mes[$mes], $beta, $i,$albedo);
                                    push(@{$mesEnergia->{$mes}},def_Eac($perdidaInversor,$longitud,$modelo,$mes,$PgfvAux,$Htinclinada));
                                     
             	}

             	case [121..151] {
             				$mes=4;
             				$Htinclinada=def_inclina($latitud,$h_Mes[$mes], $beta, $i,$albedo);
                                    push(@{$mesEnergia->{$mes}},def_Eac($perdidaInversor,$longitud,$modelo,$mes,$PgfvAux,$Htinclinada));
                                     

             	}
             	case [152..181] {
             				$mes=5;
             				$Htinclinada=def_inclina($latitud,$h_Mes[$mes], $beta, $i,$albedo);
                                    push(@{$mesEnergia->{$mes}},def_Eac($perdidaInversor,$longitud,$modelo,$mes,$PgfvAux,$Htinclinada));
                                     
             	}

             	case [182..212] {
             				$mes=6;
             				
                                    $Htinclinada=def_inclina($latitud,$h_Mes[$mes], $beta, $i,$albedo);
                                    push(@{$mesEnergia->{$mes}},def_Eac($perdidaInversor,$longitud,$modelo,$mes,$PgfvAux,$Htinclinada));
                                     

             				}
             	case [212..243] {
             				$mes=7;
             				 $Htinclinada=def_inclina($latitud,$h_Mes[$mes], $beta, $i,$albedo);
                                     push(@{$mesEnergia->{$mes}},def_Eac($perdidaInversor,$longitud,$modelo,$mes,$PgfvAux,$Htinclinada));
                                     

             				}

             	case [244..273] {
             				$mes=8;
             				$Htinclinada=def_inclina($latitud,$h_Mes[$mes], $beta, $i,$albedo);
                                    push(@{$mesEnergia->{$mes}},def_Eac($perdidaInversor,$longitud,$modelo,$mes,$PgfvAux,$Htinclinada));
                                     

             	}

             	case [274..304] {
             				$mes=9;
             				 $Htinclinada=def_inclina($latitud,$h_Mes[$mes], $beta, $i,$albedo);
                                     push(@{$mesEnergia->{$mes}},def_Eac($perdidaInversor,$longitud,$modelo,$mes,$PgfvAux,$Htinclinada));
                                     
             	}

             	case [305..334] {
             				$mes=10;
             				 $Htinclinada=def_inclina($latitud,$h_Mes[$mes], $beta, $i,$albedo);
                                     push(@{$mesEnergia->{$mes}},def_Eac($perdidaInversor,$longitud,$modelo,$mes,$PgfvAux,$Htinclinada));
                                     
             	}

             	case [335..365] {
             				$mes=11;
             				 $Htinclinada=def_inclina($latitud,$h_Mes[$mes],$beta, $i,$albedo);
                                     push(@{$mesEnergia->{$mes}},def_Eac($perdidaInversor,$longitud,$modelo,$mes,$PgfvAux,$Htinclinada));
                                     
             	}
             }
      }

  
      #acumulo por mes 
      my $mensual;
            for (my $i=0; $i<=11; $i++){
            		$mensual->{$i}=0;
            	foreach  (@{$mesEnergia->{$i}}){
            		
            		$mensual->{$i}+= $_;
            		
            	 	}
            	 
            };

      #print Dumper $mensual;
      #exit;
      my @retorno;
      my @energia;
      my $mensaje= '';
      
      for (my $i=0; $i<=11; $i++){
            if (defined $mensual->{$i}) {
                  $energia[$i]= int($mensual->{$i});
            }
            else {
                  $mensaje= "no hay valores de produccion Fotovoltaico";
            }
      }


      if ($mensaje== ''){

          push @retorno, "Done";
          push @retorno, [@energia];  
      }else {
          push @retorno, "Error";
          push @retorno, $mensaje;
          #push @retorno, [1469,1392,1565,1434,1427,1419,1608,1718,1674,1500,1399,1373];
       }
    

      if ($reporte==1){
            if ($conexion==1){
                  
                  my $nombre=Reporte::creaReporte($latitud,$longitud,$altitud,$conexion,$PgfvAux,$beta,$modelo,$eficiencia,$perdida,$tipoUsuario,@energia,@consumoMensual);
                  push @retorno, $nombre; 
            }else {
                  my $nombre=Reporte::creaReporteSinConexion($latitud,$longitud,$altitud,$conexion,$PgfvAux,$beta,$modelo,$eficiencia,$perdida,$tipoUsuario,@energia,@consumoMensual);
               
                  push @retorno, $nombre;   
            }   
      }else{
            my $nombre= "no";
            push @retorno, $nombre;   
           
      }

      return @retorno;

}

sub calcula2primeroAnos{
      my ($anual,$precioPromocional)= @_;
      return ($anual *$precioPromocional )*2; #kWh
}

sub def_inclina{

      my ($latitud,$H,$beta,$juliano,$albedo)=@_;


      my $delta = 23.45 * sin(pi/180*360*(284+ $juliano)/365);
      my $Gsc= 1366;
      my $omegaS = 180/pi* acos(-tan(pi/180*$latitud)*tan(pi/180*$delta));
      my $omegaSprima=def_omegaSprima();
      my $numerador= cos(pi/180*($latitud+$beta))*cos(pi/180*$delta)*sin(pi/180*$omegaSprima) + (pi/180*$omegaSprima*sin(pi/180*($latitud+$beta))*sin(pi/180*$delta));
      my $denominador= cos(pi/180*$latitud)*cos(pi/180*$delta)*sin(pi/180*$omegaS)+ pi/180*$omegaS*sin(pi/180*$latitud)*sin(pi/180*$delta);
      my $Rb=  $numerador/$denominador;
      my $Ho= (24 * 3600 * $Gsc/pi /3.6 /1000000) * ( 1+0.033 *cos(pi/180*360* $juliano/365)) *(cos(pi/180*$latitud)*cos(pi/180*$delta) * sin(pi/180*$omegaS) + (pi * $omegaS/180*sin(pi/180*$latitud)*sin(pi/180*$delta)) ) ;
      my $kt = $H/$Ho;

      my $Hd = 0.755+0.00606 *($omegaS-90)-(0.505+0.00455*($omegaS-90))*cos(pi/180*(115*$kt-103));
      my $betaR= pi/180*$beta;
      #my $inclinada= (1-$Hd/$H);
      #my $cociente= $Hd/$H;
      #print $cociente;
      #print $inclinada;

      #my $Ht = $H *($Rb*$inclinada + ($cociente *(1+cos($betaR))/2) + $albedo * (1-cos($betaR))/2);
     
      my $Ht = $H *($Rb*(1-$Hd/$H) + ($Hd/$H *(1+cos($betaR))/2) + $albedo * (1-cos($betaR))/2);
      #return 4.77444800230897;
      return $Ht;

}
#angulo de puesta del sol para ese plano con inclinación beta
sub def_omegaSprima{
      
      my $omegaSprima1= 180/pi* acos(-tan(pi/180*$latitud)*tan(pi/180*$delta)); 
      my $omegaSprima2= 180/pi* acos(-tan(pi/180*($latitud+$beta))*tan(pi/180*$delta));

      if ($omegaSprima1 < $omegaSprima2){return $omegaSprima1}
      else {return $omegaSprima2};


}


sub def_Eac{
      #ojo con pTemp tengo que pasar zona, modelo y mes
      my ($perdInv,$longit,$modelo, $mes,$PgfvAux,$Ht)= @_;
       my $G=1;
       $long= $longit;
       $PerdidaInversor= $perdInv ;
       $zona= def_zona($long);
       $PerdTemperatura= def_Ptemp($zona,$modelo,$mes)/100;

        #Performance ratio: contempla las perdidas tecnicas de la instalacion
      my $Pr= 1-($PerdTemperatura+$PerdidaInversor);
      
       $Pgfv= $PgfvAux;
       $H= $Ht;
       my $Eac = $Pr * $H * $Pgfv / $G;
       return $Eac;
}

sub def_zona{
      #limite con chile -68.557328
      #  -65.582290 puna return 0 la quiaca
      #  -64.399728 valle return 1
      #  -64.399728 chaco return 2
      #limite con formosa : -62.340303
      my $longitud=$_[0];


      if ($longitud >= -68.557 and $longitud <-65.582){
            return 0;#puna
      }elsif ($longitud >= -65.582 and $longitud <-64.399){
            return 1; #salta
      } elsif (-64.399 <= $longitud and $longitud <-62.340){
            return 2; #rivadavia
      } else {
            return "fuera del rango";
      };


}

#devuelve la Ptemp
sub def_Ptemp{

      my ($indice, $modelo, $mes)=@_ ;
      $Ptemp[0][3]=[(4.19,4.60,6.41,6.95,6.24,4.39,5.06,4.83,5.54,5.25,4.98,6.89)]; 
      $Ptemp[0][4]=[(12.27,13.84,16.66,18.05,17.22,14.77,15.83,15.42,15.92,14.62,13.82,-1.82)];
      $Ptemp[1][3]= [(4.71,7.41,6.53,5.23,4.42,3.46,4.40,5.01,6.08,5.83,6.40,6.83)];
      $Ptemp[1][4]=[(11.90,15.54,14.61,12.82,11.59,10.57,12.22,13.24,14.47,13.08,13.62,13.86)];
      $Ptemp[2][3]=[(12.08,12.32,10.84,8.40,6.16,3.66,5.86,8.09,10.07,8.35,8.81,11.83)];
      $Ptemp[2][4]=[(20.64,21.61,19.55,16.11,12.67,9.03,13.09,16.43,18.82,16.26,16.81,19.82)];

      
      return  $Ptemp[$indice][$modelo][$mes];
      
}
1;