package Calefon;

use Switch;
use Math::Trig;
use Data::Dumper;
use Reporte;
use ReporteTermico;
#use strict;

sub calculaNatural{
    my $datos = $_[0];

    my ($latitud,$longitud,$altitud,$cantPersonas,$tipoColector,$reporte,@RadTempCons)= split(/,/,$datos);
    my @h_Mes;
    my @tempMensual;
    my @consumo;

    for (my $i=0; $i<=11;$i++){
        push @h_Mes, $RadTempCons[$i];
    }
    for (my $i=12; $i<=23;$i++){
        push @tempMensual, $RadTempCons[$i];
    }
    for (my $i=24; $i<30;$i++){
        push @consumo, $RadTempCons[$i];
    }


    #print Dumper @h_Mes;
    #exit;
    #calculo promedio de irradiación diaria por mes a partir de acumulada mensual
    my @cantDias =(31,28,31,30,31,30,31,31,30,31,30,31);
     for (my $i=0; $i<=11;$i++) {
       @h_Mes[$i]=@h_Mes[$i]/ @cantDias[$i];
      };
     
    #calculo de temperatura de red
    my $TempMedAnual;
    for (my $i=0; $i<=11;$i++){
       $TempMedAnual += @tempMensual[$i] ;#+ @tempMensual[$i] * $sinu; 
    }
    $TempMedAnual= $TempMedAnual/12;
    
    my $TempRed;
    #my $Tamb;
    for (my $i=1; $i<=11;$i++){
        $TempRed->{$i}= $TempMedAnual+ 0.35 * ($tempMensual[$i]-$tempMensual[$i-1]);
    }
    $TempRed->{0}= $TempMedAnual+ 0.35 * ($tempMensual[0]-$tempMensual[11]);
   
    ### Calculo radiacion inclinada   
    my $beta= 30;
    my $albedo= 0.25; 
    my $mesInclinada= calculaInclinadaMensual($latitud,$beta,$albedo,@h_Mes);


    my $Fr= 0;
    my $FrUl= 0;

    if ($tipoColector==0) {
        $Fr= 0.68;
        $FrUl= 4.90;
    }
    else {
        $Fr= 0.58;
        $FrUl= 0.7;
    }
    
   
    my $Cd= $cantPersonas* 45; #supongo que consumen 45 litros por persona por dia
    my ($Fchart,$Qload) =calculaFraccion($cantPersonas,$Fr,$mesInclinada,$TempRed);

    #exit;
    my $Qutil;
    my $QutilMes;
    for (my $i=0; $i<=11;$i++){
        $QutilMes->{$i}= $Fchart->{$i} * $Qload->{$i} /10.45;
    }

  
    my $i=0;
    for (my $j=0; $j<=5;$j++){
        $Qutil->{$j}= ($QutilMes->{$i} +$QutilMes->{$i+1}) ;
        $i= $i+2;
    }


    my $FchartProm;
    $i=0;
    for (my $j=0; $j<=5;$j++){
        $FchartProm->{$j}= ($Fchart->{$i} +$Fchart->{$i+1})/2 ;
        $i= $i+2;
    }
   
    my @litroDia;
    my @retorno= ();
    my @energia;
    my $mensaje= '';
    for (my $i=0; $i<=5; $i++){
            if (defined $Fchart->{$i}) {
                  $litroDia[$i]= int($FchartProm->{$i}*100* $Cd)/100;

            }
            else {
                  $mensaje= "no hay valores de litros calientes por dia";
            }
    }

  
    for (my $i=0; $i<=5; $i++){
            if (defined $Qutil->{$i}) {
                  $energia[$i]= int($Qutil->{$i}*100)/100;
            }
            else {
                  $mensaje= "no hay valores de produccion termica";
       
            }
    }

    if ($mensaje== ''){

          push @retorno, "Done";
          push @retorno, [@energia];  
          push @retorno, [@litroDia];
          if ($reporte==1){
            my $nombreReporte= ReporteTermico::creaReporteNatural($latitud,$longitud,$altitud,$tipoColector,$cantPersonas,@consumo,@energia,@litroDia);
            push @retorno, $nombreReporte; 
          }else {
             my $nombreReporte= "no";
             push @retorno, $nombreReporte; 
          }

      }else {
          push @retorno, "Error";
          push @retorno, $mensaje;
        }

       
     return @retorno;


}

sub calculaEnvasado{
    my $datos = $_[0];

   
    my ($latitud,$longitud,$altitud,$cantPersonas,$tipoColector,$reporte,@RadTempCons)= split(/,/,$datos);
    # separo los arrays de radiacion y temperatura 

    my @h_Mes;
    my @tempMensual;
    for (my $i=0; $i<=11;$i++){

           push @h_Mes, $RadTempCons[$i];
    }
    for (my $i=12; $i<=23;$i++){
             push @tempMensual, $RadTempCons[$i];
    }
   
    my $consumo= $RadTempCons[24];

    #calculo promedio de irradiación diaria por mes a partir de acumulada mensual
    my @cantDias =(31,28,31,30,31,30,31,31,30,31,30,31);
     for (my $i=0; $i<=11;$i++) {
       @h_Mes[$i]=@h_Mes[$i]/ @cantDias[$i];
      };
    
    my $Tamb;

    for (my $i=0; $i<=11;$i++){
        $Tamb->{$i}= @tempMensual[$i];
    }
        #calculo de temperatura de red
    my $TempMedAnual;
    for (my $i=0; $i<=11;$i++){
       $TempMedAnual += @tempMensual[$i] ;#+ @tempMensual[$i] * $sinu; 
    }
    $TempMedAnual= $TempMedAnual/12;

    my $TempRed;
    for (my $i=1; $i<=11;$i++){
        $TempRed->{$i}= $TempMedAnual+ 0.35 * ($Tamb->{$i}-$Tamb->{$i-1});
    }
    
    $TempRed->{0}= $TempMedAnual+ 0.35 * ($Tamb->{0}-$Tamb->{11});

    #variables necesarias para radiación inclinada
    my $beta= 30;
    my $albedo= 0.25; 
    my $mesInclinada= calculaInclinadaMensual($latitud,$beta,$albedo,@h_Mes);

    #controlo tipo de colector y asigno Fr(tau *alpha) y Fr * Ul 
    my $Fr= 0;
    my $FrUl= 0;

    if ($tipoColector==0) {
        $Fr= 0.68;
        $FrUl= 4.90;
    }
    else {
        $Fr= 0.58;
        $FrUl= 0.7;
    }
    
     
    my $Cd= $cantPersonas* 45; #supongo que consumen 45 litros por persona por dia
    my ($Fchart,$Qload) =calculaFraccion($cantPersonas,$Fr,$mesInclinada,$TempRed);
 
    my $Qutil;
    for (my $i=0; $i<=11;$i++){
        $Qutil->{$i}= $Fchart->{$i} * $Qload->{$i} / 13.34;
    }

    my @litroDia;
    my @retorno= ();
    my @energia;
    my $mensaje= '';
    for (my $i=0; $i<=11; $i++){
            if (defined $Fchart->{$i}) {
                  $litroDia[$i]= int($Fchart->{$i}*100* $Cd)/100;

            }
            else {
                  $mensaje= "no hay valores de litros calientes por dia";
            }
    }

    for (my $i=0; $i<=11; $i++){
            if (defined $Qutil->{$i}) {
                  $energia[$i]= int($Qutil->{$i}*100)/100;
            }
            else {
                  $mensaje= "no hay valores de produccion termica";
            }
    }
    if ($mensaje== ''){

          push @retorno, "Done";
          push @retorno, [@energia];  
          push @retorno, [@litroDia];

          if ($reporte==1){
              my $nombreReporte= ReporteTermico::creaReporteEnvasado($latitud,$longitud,$altitud,$tipoColector,$cantPersonas,$consumo,@energia,@litroDia);
              push @retorno, $nombreReporte; 
          }else {
            my $nombreReporte= "no";
             push @retorno, $nombreReporte; 
          }
        
      }else {
          push @retorno, "Error";
          push @retorno, $mensaje;
       }

      
     return @retorno;

}

sub calculaElectricidad{
    my $datos = $_[0];

    my ($latitud,$longitud,$altitud,$cantPersonas,$tipoColector,$reporte,@RadTempCons)= split(/,/,$datos);
    my @h_Mes;
    my @tempMensual;
    my @consumo;

    for (my $i=0; $i<=11;$i++){

           push @h_Mes, $RadTempCons[$i];
    }
    for (my $i=12; $i<=23;$i++){
             push @tempMensual, $RadTempCons[$i];
    }
   
    for (my $i=24; $i<36;$i++){
        push @consumo, $RadTempCons[$i];
    }
    
  
    #calculo promedio de irradiación diaria por mes a partir de acumulada mensual
    my @cantDias =(31,28,31,30,31,30,31,31,30,31,30,31);
     for (my $i=0; $i<=11;$i++) {
       @h_Mes[$i]=@h_Mes[$i]/ @cantDias[$i];
      };
    
     
    #calculo de temperatura de red
    for (my $i=0; $i<=11;$i++){
        @TempRed[$i]= @tempMensual[$i] ;#+ @tempMensual[$i] * $sinu; 

    }

    for (my $i=0; $i<=11;$i++){
        $Tamb->{$i}= @tempMensual[$i];

    }
    my $TempMedAnual;
    #calculo de temperatura de red
    for (my $i=0; $i<=11;$i++){
       $TempMedAnual += @tempMensual[$i] ;#+ @tempMensual[$i] * $sinu; 
    }
    $TempMedAnual= $TempMedAnual/12;

    my $TempRed;
    for (my $i=1; $i<=11;$i++){
        $TempRed->{$i}= $TempMedAnual+ 0.35 * ($Tamb->{$i}-$Tamb->{$i-1});
    }
    
    $TempRed->{0}= $TempMedAnual+ 0.35 * ($Tamb->{0}-$Tamb->{11});

    #variables necesarias para radiación inclinada
    my $beta= 30;
    my $albedo= 0.25; 
    my $mesInclinada= calculaInclinadaMensual($latitud,$beta,$albedo,@h_Mes);

    #controlo tipo de colector y asigno Fr(tau *alpha) y Fr * Ul 
    my $Fr= 0;
    my $FrUl= 0;

    if ($tipoColector==0) {
        $Fr= 0.68;
        $FrUl= 4.90;
    }
    else {
        $Fr= 0.58;
        $FrUl= 0.7;
    }
    
      
    my $Cd= $cantPersonas* 45; #supongo que consumen 45 litros por persona por dia

    my ($Fchart,$Qload) =calculaFraccion($cantPersonas,$Fr,$mesInclinada,$TempRed);
    my $Qutil;
    for (my $i=0; $i<=11;$i++){
        $Qutil->{$i}= $Fchart->{$i} * $Qload->{$i};
    }

    my @litroDia= ();
    my @retorno= ();
    my @energia= ();
    my $mensaje= '';
    for (my $i=0; $i<=11; $i++){
            if (defined $Fchart->{$i}) {
                  $litroDia[$i]= int($Fchart->{$i}*100* $Cd)/100;
                  
            }
            else {
                  $mensaje= "no hay valores de litros calientes por dia";
            }
    }

    
    for (my $i=0; $i<=11; $i++){
            if (defined $Qutil->{$i}) {
                  $energia[$i]= int($Qutil->{$i}*100)/100;
            }
            else {
                  $mensaje= "no hay valores de produccion termica";
            }
    }

   
    if ($mensaje== ''){

          push @retorno, "Done";
          push @retorno, [@energia];  
          push @retorno, [@litroDia];
           if ($reporte==1){
             my $nombreReporte= ReporteTermico::creaReporteElectrico($latitud,$longitud,$altitud,$tipoColector,$cantPersonas,@consumo,@energia,@litroDia);
             push @retorno, $nombreReporte; 
            }else {
            my $nombreReporte= "no";
             push @retorno, $nombreReporte; 
            }
      }else {
          push @retorno, "Error";
          push @retorno, $mensaje;
        }

   return @retorno;
   
}
sub calculaSinInstalacion{
    my $datos = $_[0];

   my ($latitud,$longitud,$altitud,$cantPersonas,$tipoColector,$reporte,@RadYtemp)= split(/,/,$datos);


    my @_Mes;
    my @tempMensual;
    for (my $i=0; $i<=11;$i++){

           push @h_Mes, $RadYtemp[$i];
    }
    for (my $i=12; $i<=23;$i++){
             push @tempMensual, $RadYtemp[$i];
    }
   

    #calculo promedio de irradiación diaria por mes a partir de acumulada mensual
    my @cantDias =(31,28,31,30,31,30,31,31,30,31,30,31);
     for (my $i=0; $i<=11;$i++) {
       @h_Mes[$i]=@h_Mes[$i]/ @cantDias[$i];
      };
    
     
  

    for (my $i=0; $i<=11;$i++){
        $Tamb->{$i}= @tempMensual[$i];

    }
    my $TempMedAnual;
    #calculo de temperatura de red
    for (my $i=0; $i<=11;$i++){
       $TempMedAnual += @tempMensual[$i] ;#+ @tempMensual[$i] * $sinu; 
    }
    $TempMedAnual= $TempMedAnual/12;

    my $TempRed;
    for (my $i=1; $i<=11;$i++){
        $TempRed->{$i}= $TempMedAnual+ 0.35 * ($Tamb->{$i}-$Tamb->{$i-1});
    }
    
    $TempRed->{0}= $TempMedAnual+ 0.35 * ($Tamb->{0}-$Tamb->{11});

    #variables necesarias para radiación inclinada
    my $beta= 30;
    my $albedo= 0.25; 
    my $mesInclinada= calculaInclinadaMensual($latitud,$beta,$albedo,@h_Mes);
  

    #controlo tipo de colector y asigno Fr(tau *alpha) y Fr * Ul 
    my $Fr= 0;
    my $FrUl= 0;

    if ($tipoColector==0) {
        $Fr= 0.68;
        $FrUl= 4.90;
    }
    else {
        $Fr= 0.58;
        $FrUl= 0.7;
    }
    
   
    my $Cd= $cantPersonas* 45; #supongo que consumen 45 litros por persona por dia
  
    my ($Fchart,$Qload) =calculaFraccion($cantPersonas,$Fr,$mesInclinada,$TempRed);

   
    my $Qutil;
    for (my $i=0; $i<=11;$i++){
        $Qutil->{$i}= $Fchart->{$i} * $Qload->{$i};
    }


    my @litroDia= ();
    my @litroMes= ();
    my @retorno= ();
    my @energia= ();

   
    my $mensaje= '';
    for (my $i=0; $i<=11; $i++){
            if (defined $Fchart->{$i}) {
                  $litroDia[$i]= int($Fchart->{$i}*100* $Cd)/100;

            }
            else {
                  $mensaje= "no hay valores de litros calientes por dia";
            }
    }
    

    for (my $i=0; $i<=11; $i++){
            if (defined $Fchart->{$i}) {
                  $litroMes[$i]= int($Fchart->{$i}*100* $Cd* @cantDias[$i])/100;

            }
            else {
                  $mensaje= "no hay valores de produccion termica";
            }
    }


    if ($mensaje== ''){

          push @retorno, "Done";
          push @retorno, [@litroMes];  
          push @retorno, [@litroDia];
          if ($reporte==1){
           
             my $nombreReporte= ReporteTermico::creaReporteSinInstalacion($latitud,$longitud,$altitud,$tipoColector,$cantPersonas,@litroDia);
             push @retorno, $nombreReporte; 
            }else {
            my $nombreReporte= "no";
            push @retorno, $nombreReporte; 
            }
    }else {
          push @retorno, "Error";
          push @retorno, $mensaje;
    }

     return @retorno;
    
}
sub calculaFraccion{

    my ($cantPersonas, $Fr,$mesInclinada,$TempRed)=@_;

    my $Eabsorvida= calculaEnergiaColector($cantPersonas,$Fr,$mesInclinada);
    my $Qload= calculoQload($TempRed,$cantPersonas);
    my $D1= calculoD1($Eabsorvida,$Qload);
    my $Eperdida= calculoEnergiaPerdida($cantPersonas,$FrUl,$TempRed,$Tamb); 
    my $D2= calculoD2($Eperdida, $Qload);
    my $Fchart= calculoFchart($D1,$D2);
    return $Fchart,$Qload;

}


sub calculoFchart{
    my ($D1,$D2)= @_;
    my $Fchart, $perdida, $perdida2;
    for (my $i=0; $i<=11;$i++){
        my $D1cuadrado= $D1->{$i} **2;
        my $D2cuadrado= $D2->{$i} ** 2 ;
        my $D1cubo = $D1cuadrado * $D1->{$i};
        
        $Fchart->{$i}= (1.029 * $D1->{$i})- (0.065 * $D2->{$i} )- (0.245 * $D1cuadrado) + (0.0018 *$D2cuadrado) + (0.0215 * $D1cubo);
    }

    return $Fchart;

}
sub calculoD2{
    my ($Eperdida,$Qload)= @_;
    my $D2;
    for (my $i=0; $i<=11;$i++){
        $D2->{$i}= $Eperdida->{$i}/$Qload->{$i};
    }

    return $D2;

}
#ME FALTA SABER EL CONSUMO DIARIO EN LITROS, ¿DEPENDE DE LA CANTIDAD DE PERSONAS?
sub calculoQload{
    my ($TempRed,$cantPersonas)= @_;

    my $calorEspecificoAgua= 4187;  #esta expresado en Joules/kg °C
    my $TempUso= 55; #fijamos de acuerdo a las costumbres como 55 Grados
    my @cantDias =(31,28,31,30,31,30,31,31,30,31,30,31);
    my $consumoDiario=45*$cantPersonas; #puse por fijar algo
    my $Qload;
    for (my $i=0; $i<=11;$i++){
        $Qload->{$i}= $consumoDiario *$calorEspecificoAgua* @cantDias[$i]*($TempUso- $TempRed->{$i});
        $Qload->{$i}= $Qload->{$i} / 3600000;
        #$Qload->{$i}= $Qload->{$i} * 2 /(3 *1000000)
    }
    #print Dumper $TempRed;
    return $Qload;
}

sub calculoEnergiaPerdida{
    
    my ($cantPersonas,$FrUl,$TempRed, $Tamb)= @_;

    my $Eperdida;
    #calculo superficie de colector en fncion de cantidad de personas
    if ($cantPersonas==0 || $cantPersonas==1){
        $Sc=1;
    }else {
        $Sc= $cantPersonas * 0.5;
    }
    
    #suponemos que el almacenamiento es de 45 litros por metros cuadrados
    my $K1= (45/(75*$Sc))**(-0.25);

    my $K2, $Tacmin;
    $Tacmin=40;
    for (my  $i=0; $i<=11;$i++){
        $K2->{$i}= 11.6 + (1.18 * $Tacmin )+ (3.86 * $TempRed->{$i}) - (2.32 * $Tamb->{$i} / (100 - $Tamb->{$i}));
    }
   
    
    my @cantSegundos;
    my @cantDias =(31,28,31,30,31,30,31,31,30,31,30,31);
    for ($i=0; $i<=11;$i++){
        @cantSegundos[$i]= @cantDias[$i] * 86400; #siendo 86400 cantidad de segundos en un dia
    }
  
    my $Eperdida;
    for ($i=0; $i<=11;$i++){
        $Eperdida->{$i}= $Sc * $FrUl *(100-$Tamb->{$i}) *$K1 * $K2->{$i} ;#*@cantSegundo[$i] *$K1 * $K2->{$i};
        $Eperdida->{$i}= $Eperdida->{$i} * 2/3 /1000;
    }
    
    return $Eperdida;
}

sub calculoD1{
    my ($Eabsorvida, $Qload)= @_;

    my $D1;
    for ($i=0; $i<=11;$i++){
         $D1->{$i} = $Eabsorvida->{$i}/$Qload->{$i};
    }
    return $D1;
}

#se encuentra expresado en 
sub calculaEnergiaColector{
    my ($cantPersonas, $Fr,$Hbeta)=@_;
    
    my $Sc=1; #Sc= superficie colector
    my @cantDias =(31,28,31,30,31,30,31,31,30,31,30,31);
    if ($cantPersonas==0 || $cantPersonas==1){
        $Sc=1;
    }else {
        $Sc= $cantPersonas * 0.5;
    }

    
    my $Eabsorvida;
    for ($i=0; $i<=11;$i++){
        $Eabsorvida->{$i}= $Sc * $Fr * $Hbeta->{$i} ;
    }

    return $Eabsorvida;
}


#Gsc  1366 w/m^2 según autor= Gueymard 2.004
sub calculaCargaTermica{
    my ($Fr, $FrUl, $cantPersonas,$Hbeta, $TempRed, $Tamb) = @_;
    
    my @cantDias =(31,28,31,30,31,30,31,31,30,31,30,31);

    if ($cantPersonas==0 || $cantPersonas==1){
        $Sc=1;
    }else {
        $Sc= $cantPersonas * 0.5;
    }
    #my $G= 1366; #W/m^2
    my $Qcol;
    for ($i=0; $i<=11;$i++){
         $Qcol->{$i}= ($Fr * $Hbeta->{$i}) - ($FrUl * (18-$Tamb->{$i})) ;
         $Qcol->{$i} = $Qcol->{$i} * @cantDias[$i] * $Sc ;
    }

  
    return $Qcol;
}


sub calculaInclinadaMensual{

 my ($latitud,$beta,$albedo,@h_Mes)= @_;


my  $Htinclinada, $mesInclinada;

for (my $i=1; $i < 366; $i++) {
             
             switch ($i){
                case [0..31] {
                            $mes=0;
                        
                            $Htinclinada=def_inclina($latitud,$h_Mes[$mes], $beta, $i,$albedo);
                        
                            push(@{$mesInclinada->{$mes}},$Htinclinada);
                        
                            }


                case [32..59] {
                            $mes=1;
                            $Htinclinada=def_inclina($latitud,$h_Mes[$mes], $beta, $i,$albedo);
                                    push(@{$mesInclinada->{$mes}},$Htinclinada); 
                                    
                              }

                case [59..90] {
                            $mes=2;
                            
                                    $Htinclinada=def_inclina($latitud,$h_Mes[$mes], $beta, $i,$albedo);
                                    push(@{$mesInclinada->{$mes}},$Htinclinada); 
                }

                case [91..120] {
                            $mes=3;
                            $Htinclinada=def_inclina($latitud,$h_Mes[$mes], $beta, $i,$albedo);
                                    push(@{$mesInclinada->{$mes}},$Htinclinada); 
                }

                case [121..151] {
                            $mes=4;
                            $Htinclinada=def_inclina($latitud,$h_Mes[$mes], $beta, $i,$albedo);
                                    push(@{$mesInclinada->{$mes}},$Htinclinada); 

                }
                case [152..181] {
                            $mes=5;
                            $Htinclinada=def_inclina($latitud,$h_Mes[$mes], $beta, $i,$albedo);
                                    push(@{$mesInclinada->{$mes}},$Htinclinada); 
                }

                case [182..212] {
                            $mes=6;
                            
                                    $Htinclinada=def_inclina($latitud,$h_Mes[$mes], $beta, $i,$albedo);
                                    push(@{$mesInclinada->{$mes}},$Htinclinada); 

                            }
                case [212..243] {
                            $mes=7;
                             $Htinclinada=def_inclina($latitud,$h_Mes[$mes], $beta, $i,$albedo);
                                     push(@{$mesInclinada->{$mes}},$Htinclinada);

                            }

                case [244..273] {
                            $mes=8;
                            $Htinclinada=def_inclina($latitud,$h_Mes[$mes], $beta, $i,$albedo);

                                    push(@{$mesInclinada->{$mes}},$Htinclinada); 

                }

                case [274..304] {
                            $mes=9;
                             $Htinclinada=def_inclina($latitud,$h_Mes[$mes], $beta, $i,$albedo);
                                     push(@{$mesInclinada->{$mes}},$Htinclinada); 
                }

                case [305..334] {
                            $mes=10;
                             $Htinclinada=def_inclina($latitud,$h_Mes[$mes], $beta, $i,$albedo);
                                     push(@{$mesInclinada->{$mes}},$Htinclinada); 
                }

                case [335..365] {
                            $mes=11;
                             $Htinclinada=def_inclina($latitud,$h_Mes[$mes],$beta, $i,$albedo);
                                
                                     push(@{$mesInclinada->{$mes}},$Htinclinada); 
                }
             }
      }

  
      #acumulo por mes 
      my $mensual;
            for (my $i=0; $i<=11; $i++){
                    $mensual->{$i}=0;
                foreach  (@{$mesInclinada->{$i}}){
                    
                    $mensual->{$i}+= $_;
                    
                    }
                 
            };

            #borro para que no acumule
              for (my $i=0; $i<=11; $i++){
                foreach  (@{$mesInclinada->{$i}}){
                     $_=0;
                    
                    }
                 
            };
            
            

      return  $mensual;  
        

}
sub def_inclina{

            my ($latitud,$H,$beta,$juliano,$albedo)=@_;


            my $delta = 23.45 * sin(pi/180*360*(284+ $juliano)/365);
            my $Gsc= 1366;
            my $omegaS = 180/pi* acos(-tan(pi/180*$latitud)*tan(pi/180*$delta));
            
            my $omegaSprima1= 180/pi* acos(-tan(pi/180*$latitud)*tan(pi/180*$delta)); 
            my $omegaSprima2= 180/pi* acos(-tan(pi/180*($latitud+$beta))*tan(pi/180*$delta));
            my $omegaSprima;
            if ($omegaSprima1 < $omegaSprima2){$omegaSprima= $omegaSprima1}
            else { $omegaSprima=$omegaSprima2};

            my $numerador= cos(pi/180*($latitud+$beta))*cos(pi/180*$delta)*sin(pi/180*$omegaSprima) + (pi/180*$omegaSprima*sin(pi/180*($latitud+$beta))*sin(pi/180*$delta));
            my $denominador= cos(pi/180*$latitud)*cos(pi/180*$delta)*sin(pi/180*$omegaS)+ pi/180*$omegaS*sin(pi/180*$latitud)*sin(pi/180*$delta);
            my $Rb=  $numerador/$denominador;
            my $Ho= (24 * 3600 * $Gsc/pi /3.6 /1000000) * ( 1+0.033 *cos(pi/180*360* $juliano/365)) *(cos(pi/180*$latitud)*cos(pi/180*$delta) * sin(pi/180*$omegaS) + (pi * $omegaS/180*sin(pi/180*$latitud)*sin(pi/180*$delta)) ) ;
            my $kt = $H/$Ho;

            my $Hd = 0.755+0.00606 *($omegaS-90)-(0.505+0.00455*($omegaS-90))*cos(pi/180*(115*$kt-103));
            my $betaR= pi/180*$beta;

            my $Ht = $H *($Rb*(1-$Hd/$H) + ($Hd/$H *(1+cos($betaR))/2) + $albedo * (1-cos($betaR))/2);

            return $Ht;

}


1;




