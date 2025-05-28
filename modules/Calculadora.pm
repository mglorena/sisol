#!/usr/bin/perl
#
# @File Calculadora.pm
# @Author root
# @Created Jul 27, 2017 6:21:24 PM
# Modulo que inclina la radiacion recibida
# Duffie and Beckman 104, capitulo 2.19: Average Radiation on Sloped Surfaces: Isotropi Sky edicion Judith 
# Dia caracteristico
# parametros de entrada: latitud, la radiacion mensual dividida por la cantidad de dias, día juliano, beta inclinación del panel
# azimut considerado 180, es decir mirando al norte
# package Radiacion;

package Calculadora;

use Math::Trig;
use Data::Dumper;
use CGI;
use Data::Dumper;
use LWP::UserAgent;
use Parse::RecDescent;
use Regexp::Grammars; 
use JSON::XS qw(encode_json decode_json);
use Conf;
#use File::Slurp qw(read_file write_file);


# $type={d,m,a} y $mes= "Enero" "Febrero" "Marzo"
# devolver un vector con cuatro posiciones= (radiacion, inclinada, etc..)
sub GetRadiacion{
    my ($lat,$long,$type) = @_;
    
    my @retorno;
    my $json;
    if (isInSalta($lat,$long))
    {

        my $ua = LWP::UserAgent->new;

        my @boundingBox = boundingBox($lat,$long);
        
        # bounding box fuera de salta
        #my $url= "http://localhost:8080/geoserver/sisol/wms?SERVICE=WMS&VERSION=1.1.1&REQUEST=GetFeatureInfo&FORMAT=image%2Fpng&TRANSPARENT=true&QUERY_LAYERS=sisol%3Adatos&STYLES&LAYERS=datos%3Adatos&INFO_FORMAT=application%2Fjson&FEATURE_COUNT=50&X=50&Y=50&SRS=EPSG%3A4326&WIDTH=101&HEIGHT=101&BBOX=".$boundingBox[0]."%2C".$boundingBox[2]."%2C".$boundingBox[3]."%2C".$boundingBox[1];
       
        my $url = $Conf::hostGeoDatos."&BBOX=".$boundingBox[0]."%2C".$boundingBox[3]."%2C".$boundingBox[2]."%2C".$boundingBox[1];  
        
        my $req= HTTP::Request->new(GET => $url);
        
        my $res = $ua->request($req);
 
        my @devolucion;
        

        if ($res->is_success)  {

            if ($res->as_string=~ /\{\"type\"\:\"FeatureCollection\"\,\"totalFeatures\"\:\"unknown\"\,\"features\"\:\[\]/){
                push @retorno, "Error";
                  my $mensaje= "No esta en Salta";
                push @retorno, $mensaje;
                return @retorno;
            }
            else {
            @dia=parserDia($res->as_string); 

            @mes= parserMes($res->as_string); 
            @anual= parserAnual($res->as_string);
            $indice;
            
            my $output;
            my @year;
           
                #devuelve horizontal, inclinada, directa y difusa
                push @year, @anual;
                push @year, int($anual[0]*80)/100;
                push @year, int($anual[0]*75)/100;
                push @year, int(($anual[0] -($anual[0]*75/100))*100)/100;
                
              
                        
            if ($type =~ /^d/){
                $type =~ s/^d//;
                $indice= def_Mes($type);
                
            }
            elsif ($type =~ /^m/){
                $type =~ s/^m//;
                $indice= def_Mes($type);
                
                
            }
        
            if ($type =~ /^anual/){
            

               
                push @output, [@dia];
                push @output, [@mes];
                push @output, [];
                push @output, [];
                push @output, [@year];
            
            }
            else{   

                $indice = $indice -1 ;

                my @valorDia;

                push @valorDia,componentesDia($type,$lat,$dia[$indice]);
                $valorDia[1]= int($valorDia[1]*100)/100;
                $valorDia[2]= int($valorDia[2]*100)/100;
                my @radDiaInclinada= radiacionDiaInclinada($type,30, $lat,$dia[$indice]);
                $radDiaInclinada[0]= int($radDiaInclinada[0]*100)/100;

                my @valDia;
                push @valDia, $valorDia[0];
                push @valDia, $radDiaInclinada[0];
                push @valDia, $valorDia[1];
                push @valDia, $valorDia[2];
                push @devolucion, @mes;
                

                #valor mensual: global,inclinada, directa, difusa
                my @valMes;
                my @valorMes;
                push @valorMes, componentesMes($type,$lat,$mes[$indice]);  

                push @valMes, $valorMes[0];    
                push @valMes, $radDiaInclinada[0] * def_cantDias($type);
                push @valMes, int($valorMes[1]*100)/100; 
                push @valMes, int($valorMes[2]*100)/100; 

                push @output, [@dia];
                push @output, [@mes];
                push @output, [@valDia];
                push @output, [@valMes];
                push @output, [@year];
                          
                }
                
            }
               
                
                my $url2= "http://localhost:8080/geoserver/sisol/wms?SERVICE=WMS&VERSION=1.1.1&REQUEST=GetFeatureInfo&FORMAT=image%2Fpng&TRANSPARENT=true&QUERY_LAYERS=sisol%3AdatosTemperatura&STYLES&LAYERS=sisol%3AdatosTemperatura&INFO_FORMAT=application%2Fjson&FEATURE_COUNT=50&X=50&Y=50&SRS=EPSG%3A4326&WIDTH=101&HEIGHT=101&BBOX=".$boundingBox[0]."%2C".$boundingBox[3]."%2C".$boundingBox[2]."%2C".$boundingBox[1];
                my $req2= HTTP::Request->new(GET => $url2);
                my $res2 = $ua->request($req2);

                if ($res2->is_success)  {

                    if ($res2->as_string=~ /\{\"type\"\:\"FeatureCollection\"\,\"totalFeatures\"\:\"unknown\"\,\"features\"\:\[\]/){
                        push @retorno, "Error";
                        my $mensaje= "No esta en Salta - Temperatura";
                        push @retorno, $mensaje;
                
                        return @retorno;
                    }
                    else {

                        #push @retorno, "Done";
            
                        my @temperatura= parserTemperatura($res2->as_string); 
                      
                        push @output, [@temperatura];
        
                        
                     } 
                push @retorno, "Done";
                push @retorno, @output;
                return @retorno;
            }
        } 
        else 
        {
            push @retorno, "Error";
            my $mensaje= "Failed: ". $res->status_line;
            push @retorno, $mensaje;
            return @retorno;
            #$json= encode_json(\@retorno);
            #return $json;

        }
         
            push @retorno, "Error";
            my $mensaje= "no paso nada";
            push @retorno, $mensaje;
            return @retorno;
            #$json= encode_json(\@retorno);
            #return $json;
    } 
    else 
    { 
        
        push @retorno, "Error";
        my $mensaje= "No pasa nada ";
        push @retorno, $mensaje;
        return @retorno;
           #return "Failed: ", $res->status_line, "\n";
        #$json= encode_json(\@retorno);
        #return $json;
    }

}

sub parserDia{
    my ($sentence)= @_;

    $parser = qr{
        <Block>

        <rule: Block>   <[cadena]>+


        <rule: cadena>  \"<mes>\"\: <numeros>\,|\"mesEnero\"\:

        <rule: mes>      Enero|Febrero|Marzo|Abril|Mayo|Junio|Julio|Agosto|Setiembre|Octubre|Noviembre|Diciembre

        <rule: numeros>      [.0-9]+   


    }xms ;


        $sentence =~ s/$parser//;
    
        my @radiacionDia;

        my @parser= %/{Block}->{cadena};

        for (my $i=0; $i<12; $i++){
            push @radiacionDia, @parser[0]->[$i]->{numeros};

        }
        

        return @radiacionDia;
    }

sub parserMes{
    my ($sentence)= @_;

    $parser = qr{
        <Block>

        <rule: Block>   <[cadena]>+

        <rule: cadena>  \"mes<mes>\"\: <numeros>\,|\"mes<mes>\"\: <numeros>\}

        <rule: mes>      Enero|Febrero|Marzo|Abril|Mayo|Junio|Julio|Agosto|Setiemb|Octubre|Noviemb|Diciemb|Anual

        <rule: numeros>      [.0-9]+   


    }xms ;

        $sentence =~ s/$parser//;
        
        my @radiacionMes;
        #my @p = %/{Block}->{cadena};
        
        my @parser= %/{Block}->{cadena};


            for (my $i=0; $i<12; $i++){
            push @radiacionMes, @parser[0]->[$i]->{numeros};

        }
        #print Dumper @radiacionMes;
        return @radiacionMes;

    }

sub parserAnual{
    my ($sentence)= @_;

    $parser = qr{
        <Block>

        <rule: Block>   <[cadena]>+

        <rule: cadena>  \"mes<mes>\"\: <numeros>\}

        <rule: mes>      Anual

        <rule: numeros>      [.0-9]+   


    }xms ;

        $sentence =~ s/$parser//;
    
        
        my @parser= %/{Block}->{cadena};
        my @radiacionAnual=  @parser[0]->[0]->{numeros};
        
        return @radiacionAnual;

    }

 sub isInSalta{
    my ($lat,$long)= @_;
    my $westLimit= -68.5821533203125;
    my $eastLimit= -62.33299255371094;
    my $northLimit= -21.993988560906036;
    my $southLimit= -26.394945029678645;
    if ($westLimit<$long && $long<$eastLimit && $lat >$southLimit && $lat< $northLimit ){
        return "true";

        } else{
            return "false";
        }   
    }
 sub boundingBox{
        my ($lat,$long)= @_;
        my $westLimit= $long;
        my $eastLimit= $long +0.001;
        my $northLimit= $lat;
        my $southLimit= $lat+ 0.001;
        return ($westLimit,$southLimit,$eastLimit,$northLimit);
    }

sub parserTemperatura{
    my ($sentence)= @_;

    $parser = qr{
        <Block>

        <rule: Block>   <[cadena]>+


        <rule: cadena>  "t<mes>\"\: <numeros>\,|\"tanual\"\:<numeros>\}

        <rule: mes>      enero|febrero|marzo|abril|mayo|junio|julio|agosto|septiembr|octubre|noviembre|diciembre

        <rule: numeros>      [.0-9]+ | \-[.0-9]+  


    }xms ;


        $sentence =~ s/$parser//;
    
        my @temperatura;
        #print Dumper %/{Block}->{cadena};
        #exit;

        my @parser= %/{Block}->{cadena};

        for (my $i=0; $i<13; $i++){
            push @temperatura, @parser[0]->[$i]->{numeros};

        }
        

        return @temperatura;
    }


# #Ht kWh/m^2
# # mes de Enero...Diciembre
# # H radiacion global acumulada diaria  horizontal
#   # Ho radiacion global acumulada extraterrestre sobre plano horizontal
#   # Gsc  1366 w/m^2 según autor= Gueymard 2.004
#   # Gsc 1353 w/m^2 segun autor = Nasa
#   # $latitud = grados
# # beta es la inclinación
# #Ho radiacion global extraterrestre
# # dividiendo por 3.6 y por 100000 se pasa de MJ/m^2 a kWh/m^2


# entrega global inclinada, componente directa, componente difusa.
sub radiacionDiaInclinada{
    my ($mes, $beta, $latitud, $H)=@_;


    my $juliano= this.def_diaJuliano($mes);

    my $delta = 23.45 * sin(pi/180*360*(284+ $juliano)/365);
    my $Gsc= 1366;
    
    #acoseno toma decimales y pasa a 
    # las funciones trigonometricas procesan angulos en radianes, por lo tanto hay que convertir los angulos en grados a radianes
    # con pi/180 antes de ser procesados por las funciones
    # las funciones trigonometricas inversas entregan resultados en radianes por lo tanto hay que pasarlos a grados con el 180/pi

    my $omegaS= 180/pi* acos(-tan(pi/180*$latitud)*tan(pi/180*$delta));

    my $Ho= (24 * 3600 * $Gsc/pi /3.6 /1000000) * ( 1+0.033 *cos(pi/180*360* $juliano/365)) *(cos(pi/180*$latitud)*cos(pi/180*$delta) * sin(pi/180*$omegaS) + (pi * $omegaS/180*sin(pi/180*$latitud)*sin(pi/180*$delta)) ) ;

    #kt es un "indice de claridad" relacion entre la radiacion que llega a la superficie con respecto a la que llega a la atmosfrea,
    # ambas horizontales
    my $kt= $H/$Ho;

    #angulo de puesta del sol para ese plano con inclinación beta
    my $omegaSprima;    
    my $omegaSprima1= 180/pi* acos(-tan(pi/180*$latitud)*tan(pi/180*$delta)); 
    my $omegaSprima2= 180/pi* acos(-tan(pi/180*($latitud+$beta))*tan(pi/180*$delta));

    if ($omegaSprima1 < $omegaSprima2){$omegaSprima= $omegaSprima1}
    else {$omegaSprima= $omegaSprima2};


    #el factor Rb: relacin entre la radiacion directa promedio diario sobre el plano inclinado con respecto a la radiacion directa promedio diario horizontal

    my $numerador= cos(pi/180*($latitud+$beta))*cos(pi/180*$delta)*sin(pi/180*$omegaSprima) + (pi/180*$omegaSprima*sin(pi/180*($latitud+$beta))*sin(pi/180*$delta));
    my $denominador= cos(pi/180*$latitud)*cos(pi/180*$delta)*sin(pi/180*$omegaS)+ pi/180*$omegaS*sin(pi/180*$latitud)*sin(pi/180*$delta);
    my $Rb=  $numerador/$denominador;

    #   cos(pi/180*($latitud+$beta))*cos(pi/180*$delta)*sin(pi/180*$omegaSprima)) + ($omegaSprima*sin(pi/180*($latitud+$beta))*sin(pi/180*$delta)))/((cos(pi/180*$latitud)*cos(pi/180*$delta)*sin(pi/180*$omegaS))+($omegaS*sin(pi/180*$latitud)*sin(pi/180*$delta)));
    

    my @radiacionDia;

    
    #Liu Jordan: se calcula la radiacion global acumulado sobre el plano inclinado 
    #$radiacionDia{Htt} = $H *($Rb*(1-$Hd/$H) + ($Hd/$H *(1+cos(pi/180*$beta))/2) + $albedo * (1-cos(pi/180*$beta))/2);
    my $Htt= $H *($Rb*(1-$Hd/$H) + ($Hd/$H *(1+cos(pi/180*$beta))/2) + $albedo * (1-cos(pi/180*$beta))/2);
    push @radiacionDia, $Htt;

# Proporción de difusa con respecto a global Hd/H ; si bien se llama Hd es Hd/
#   
    my $Hdt= (0.755+0.00606 *($omegaS-90)-(0.505+0.00455*($omegaS-90))*cos(pi/180*(115*$kt-103)))* $Htt;
    my $Hbt= $Htt - $Hdt;

    push @radiacionDia, $Hbt;

    push @radiacionDia, $Hdt;
    return @radiacionDia;
    
 }

sub componentesMes{

    my ($mes,$latitud, $Hmes)=@_;
    $mes = 'enero';
    #print Dumper @_;
    #exit;
    my $Gsc= 1366;
    my $juliano= this.def_diaJuliano($mes);
    my $delta = 23.45 * sin(pi/180*360*(284+ $juliano)/365);
    my $omegaS= 180/pi* acos(-tan(pi/180*$latitud)*tan(pi/180*$delta));
    
    #print pi, $Gsc ,",",$juliano,",", $delta, ",",$omegaS;
    
    my $Ho= (24 * 3600 * $Gsc/pi /3.6 /1000000) * ( 1+0.033 *cos(pi/180*360* $juliano/365)) *(cos(pi/180*$latitud)*cos(pi/180*$delta) * sin(pi/180*$omegaS) + (pi * $omegaS/180*sin(pi/180*$latitud)*sin(pi/180*$delta)) ) ;
  
    my $Haverage= $Hmes/def_cantDias($mes);
    
    my $kt= $Haverage/ $Ho;
    
    my $Hdifmes;
    if ($omegaS > 81.4 && $kt>=0.3 && $kt<=0.8){
        $Hdifmes= (1.391 - (3.560 * $kt )+ (4.189 * ($kt **2)) - (2.137 * ($kt **3)))  * $Haverage;

    }
    else {
        
        $Hdifmes= (1.311 - (3.022 * $kt )+ (3.427 * ($kt **2)) - (1.821 * ($kt **3)) ) * $Haverage;
    }

    my @radiacionMes;


    push @radiacionMes,$Hmes;
    $Hdifmes = $Hdifmes * def_cantDias($mes);

    if ($Hdifmes>($Hmes - $Hdifmes)){
        push @radiacionMes, $Hdifmes;
        push @radiacionMes, ($Hmes - $Hdifmes);
    }
    else{
        push @radiacionMes, ($Hmes - $Hdifmes);
        push @radiacionMes, $Hdifmes;
    }
    
    
    
    

    return @radiacionMes;

 }

sub componentesDia{
    my ($mes, $latitud, $Hdia)=@_;
    
    my $Gsc= 1366;
    my $juliano= this.def_diaJuliano($mes);
    my $delta = 23.45 * sin(pi/180*360*(284+ $juliano)/365);
    my $omegaS= 180/pi* acos(-tan(pi/180*$latitud)*tan(pi/180*$delta));
    my $Ho= (24 * 3600 * $Gsc/pi /3.6 /1000000) * ( 1+0.033 *cos(pi/180*360* $juliano/365)) *(cos(pi/180*$latitud)*cos(pi/180*$delta) * sin(pi/180*$omegaS) + (pi * $omegaS/180*sin(pi/180*$latitud)*sin(pi/180*$delta)) ) ;
    my $kt= $Hdia/ $Ho;
    my $Hdif;

    if ($omegaS<= 81.4){
        if ($kt < 0.715){
            $Hdif= (1 - (0.2727 * $kt) + (2.4495 * ($kt **2)) - (11.9514 * ($kt **3)) + (9.3879* ($kt **4)) ) * $Hdia;
        
        } else {

            $Hdif= 0.175 * $Hdia;
        }
    }
    else {
        if ($kt < 0.722){
            $Hdif= (1.0 + (0.2832 * $kt) - (2.5557 * ($kt **2)) + (0.8448 * ($kt**3)))*$Hdia;
            }else {
            $Hdif= 0.175 * $Hdia;
            }
    }
    my @radiacionDia;

    #devuelve la horizontal, la difusa y la directa

    push @radiacionDia,$Hdia;
    push @radiacionDia, $Hdif;
    push @radiacionDia, $Hdia - $Hdif;
    return @radiacionDia;

 }

# # A partir del mes (Enero, Febrero, ..) me da el numero de dia caracteristico
 sub def_diaJuliano{
         my ($mes)= @_;

         my %diaJuliano;

         $diaJuliano{"enero"}=17;
         $diaJuliano{"febrero"}=47;
         $diaJuliano{"marzo"}=75;
         $diaJuliano{"abril"}=105;
         $diaJuliano{"mayo"}=135 ;
         $diaJuliano{"junio"}=162;
         $diaJuliano{"julio"}=198;
         $diaJuliano{"agosto"}=228;
         $diaJuliano{"septiembre"}=258;
         $diaJuliano{"octubre"}=288;
         $diaJuliano{"noviembre"}=318;
         $diaJuliano{"diciembre"}=344;

         #print Dumper \%diaJuliano;
         return $diaJuliano{$mes} ;

}
 
 sub def_cantDias{
         my ($mes)= @_;

         my %diaJuliano;

         $diaJuliano{"enero"}=31;
         $diaJuliano{"febrero"}=28;
         $diaJuliano{"marzo"}=31;
         $diaJuliano{"abril"}=30;
         $diaJuliano{"mayo"}= 31;
         $diaJuliano{"junio"}=30;
         $diaJuliano{"julio"}=31;
         $diaJuliano{"agosto"}=31;
         $diaJuliano{"septiembre"}=30;
         $diaJuliano{"octubre"}=31;
         $diaJuliano{"noviembre"}=30;
         $diaJuliano{"diciembre"}=31;

         #print Dumper \%diaJuliano;
         return $diaJuliano{$mes} ;

}

 sub def_cantDias2{
         my ($mes)= @_;

         my %diaJuliano;

         $diaJuliano{0}=31;
         $diaJuliano{1}=28;
         $diaJuliano{2}=31;
         $diaJuliano{3}=30;
         $diaJuliano{4}= 31;
         $diaJuliano{5}=30;
         $diaJuliano{6}=31;
         $diaJuliano{7}=31;
         $diaJuliano{8}=30;
         $diaJuliano{9}=31;
         $diaJuliano{10}=30;
         $diaJuliano{11}=31;

         #print Dumper \%diaJuliano;
         return $diaJuliano{$mes} ;

}

sub def_Mes{

    my ($mes)= @_;
     my %diaJuliano;
     $diaJuliano{"enero"}=1;
     $diaJuliano{"febrero"}=2;
     $diaJuliano{"marzo"}=3;
     $diaJuliano{"abril"}=4;
     $diaJuliano{"mayo"}=5 ;
     $diaJuliano{"junio"}=6;
     $diaJuliano{"julio"}=7;
     $diaJuliano{"agosto"}=8;
     $diaJuliano{"septiembre"}=9;
     $diaJuliano{"octubre"}=10;
     $diaJuliano{"noviembre"}=11;
     $diaJuliano{"diciembre"}=12;


     return $diaJuliano{$mes};
}

 
1;
