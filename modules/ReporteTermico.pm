package ReporteTermico;

use strict;
use warnings;
use PDF::API2;
use PDF::Table;
use GD::Graph::mixed;
use GD::Graph::Data;
use GD::Graph::lines;
use PDF::Reuse;
use utf8;
use Time::Local;
use POSIX qw/strftime/;
use Data::Dumper;
use Conf;


 my $path=$Conf::reportesURL;
sub creaReporteNatural{


   my ($latitud,$longitud,$altitud,$tipoColector,$cantPersonas,@genConsLit)= @_;
   #($latitud,$longitud,$altitud,$tipoColector,$cantPersonas,@genConsLit)= split(/,/,$datos);
  
  my @generacion;
  my @consumo;
  my @litros;
  for (my $i=0; $i<6;$i++){
    push @consumo, int($genConsLit[$i]);
  }
  for (my $i=6; $i<12;$i++){
    push @generacion, int($genConsLit[$i]);
  }

  for (my $i=12; $i<18;$i++){
    push @litros, int($genConsLit[$i]);
  }

  
  my $TEMPLATE = $path.'files/reportes/termico/headers/tresHojas.pdf';
  my $REPORTE= $path. 'files/reportes/termico/';
  my $PNG= $path.'files/reportes/termico/grafico/';
  my $pdf = PDF::API2->open($TEMPLATE);
  my $page    = $pdf->openpage('1');
  my $text    = $page->text();
  my $font    = $pdf->corefont('Times-Bold');

  $text->translate(213,680); 
  $text->font($font,12); 
  $text->text("Reporte de Generación de Agua Caliente Sanitaria");

  $text->translate(30,640); 
  $text->text("1. Parámetros de la Simulación");
  $font    = $pdf->corefont('Times-Roman');
  $text->font($font,12); 
  $text->translate(30,600); 
   $font    = $pdf->corefont('Times-Bold');
  $text->font($font,12); 
  $text->text("Sistema utilizado para el Agua Caliente Sanitaria: ");
  $font    = $pdf->corefont('Times-Roman');
  $text->font($font,12); 
  $text->text("  Gas Natural");

  $font    = $pdf->corefont('Times-Bold');
  $text->font($font,12);
  $text->translate(30,550);
  $text->text("Lugar Geográfico:");

  $text->translate(150,550);
  $text->text("Latitud");

  $text->translate(270,550);
  $text->text("Longitud");

  $text->translate(390,550);
  $text->text("Altitud");

  $text->translate(510,550);
  $text->text("Pais");

  $text->translate(30,500);  #primero se mueve en la misma fila,distinta columna. Segundo mas cerca del 0 mas abajo en la hoja
  $text->text("Huso horario:");

  $text->font($pdf->corefont('Times-Roman'),12); 
  $text->translate(150,525);
  $text->text($latitud);

  $text->translate(280,525);
  $text->text($longitud);

  $text->translate(395,525);
  $text->text($altitud ."m");

  $text->translate(500,525);
  $text->text("Argentina");

  $text->translate(200,500);  #primero se mueve en la misma fila,distinta columna. Segundo mas cerca del 0 mas abajo en la hoja
  $text->text("UTC- 03:00");

  $text->font($pdf->corefont('Times-Bold'),12); 
  $text->translate(30,475);  
  $text->text("Tipo de Calefón Solar:");
  $text->translate(30,450);  
  $text->text("Orientación de los Paneles:");


  $font    = $pdf->corefont('Times-Roman');
  $text->font($font,12);
  $text->translate(200,475);
  if ($tipoColector==1){
  $text->text("Plano");
  }else {
   $text->text("Tubo De Vacío");
  }
  my $inclinacion = 30;
  $text->translate(200,450);  
  $text->text("Inclinación = ".$inclinacion."°"); 
  $text->translate(400,450);  
  $text->text("Azimut = 0° (orientación Norte)");
  $font = $pdf->corefont('Times-Bold');
  $text->font($font,12);
  $text->translate(30,425);  
  $text->text("Superficie del colector:");
  $text->translate(30,400);  
  $text->text("Cantidad de Personas residentes en la vivienda:");

  my $supCol=1;
  if ($cantPersonas==1 or $cantPersonas==1 ){
    $supCol= 1;
     $font = $pdf->corefont('Times-Roman');
    $text->font($font,12);
    $text->translate(300,425);  
    $text->text($supCol ." metro cuadrado");
  }else {
    $supCol= $cantPersonas * 0.5;
     $font = $pdf->corefont('Times-Roman');
    $text->font($font,12);
    $text->translate(300,425);  
    $text->text($supCol ." metros cuadrados");
  }

  $text->translate(300,400);  
  $text->text($cantPersonas. " personas");


  my ($s, $min, $h, $d, $m, $y) = localtime();
  my $time = timelocal $s, $min, $h, $d, $m, $y;
  my $today= strftime "%d-%m-%Y", localtime $time; 
    $font    = $pdf->corefont('Times-Roman'); 
  $text->font($font,10);
  $text->translate(50,115); 
  $text->text("** Los resultados arrojados por el presente reporte son estimativos. Los mismos pueden presentar variaciones propias del sis-");
  $text->translate(53,100); 
  $text->text("tema, de los datos aportados, de las revisiones tarifarias y/o de las fluctuaciones climáticas, no asumiendo responsabilidad ni");
  $text->translate(53,85); 
  $text->text("obligacion por los resultados obtenidos");
  $text->translate(513,60); 
  $text->text("Página: 1");
  $text->translate(50,60); 
  $text->text("Fecha:". $today);

###########################2 hojas######


  $page    = $pdf->openpage('2');
  my $pdftable = new PDF::Table;
   $text    = $page->text();
  $font    = $pdf->corefont('Times-Roman');

  $text->translate(30,700);  #primero se mueve en la misma fila,distinta columna. Segundo mas cerca del 0 mas abajo en la hoja
  $font = $pdf->corefont('Times-Bold');
  $text->font($font,12);
  $text->text("2. Consumo Total de Gas Natural y Ahorro de Agua Caliente Sanitaria (m3)");
  $font = $pdf->corefont('Times-Roman');
  $text->font($font,12);
  $text->translate(50,660);  
  $text->text("La siguiente tabla presenta un resumén mensual del consumo de gas natural total y la generación de agua ");
  $text->translate(50,640); 
  $text->text("caliente sanitaria producida por el calefón solar. Ambos valores se encuentran expresados en m3. Es  im-");
   $text->translate(50,620); 
  $text->text("portante destacar que el gas natural consumido integra: cocción de alimentos, calefacción y calentamien-");
   $text->translate(50,600); 
  $text->text("to de agua. ");


# de agua.
####creacion de tabla

 my $hdr_props = 
  {
          # This param could be a pdf core font or user specified TTF.
          #  See PDF::API2 FONT METHODS for more information
          font       => $pdf->corefont("Times", -encoding => "utf-8"),
          font_size  => 14,
          font_color => '#141313', # #006666
          bg_color   => 'white',
         repeat     => 1,    # 1/0 eq On/Off  if the header row should be repeated to every new       page
      };
my $some_data =[
["Mes",
" Consumo Total [m3]",
" Ahorro de A.C.S [m3]",
" Generación de A.C.S [litros por día]"],
["Ene-Feb",
"         $consumo[0]",
"         $generacion[0]",
"         $litros[0]"],
["Mar-Abr",
"         $consumo[1]",
"         $generacion[1]",
"         $litros[1]"],
["May-Jun",
"         $consumo[2]",
"         $generacion[2]",
"         $litros[2]"],
["Jul-Ago",
"         $consumo[3]",
"         $generacion[3]",
"         $litros[3]"],
["Sep-Oct",
"         $consumo[4]",
"         $generacion[4]",
"         $litros[4]"],
["Nov-Dic",
"         $consumo[5]",
"         $generacion[5]",
"         $litros[5]"],
];


 my $left_edge_of_table = 50;
   # build the table layout
  $pdftable->table(
  
    $pdf,
    $page,
    $some_data,
    x => $left_edge_of_table,
    w => 495,
    start_y => 540,
    next_y  => 520,
    start_h => 300,
    next_h  => 500,
    # some optional params
     padding => 5,
     padding_right => 10,
     #background_color_odd  => shift @_ || "#FFFFFF",
     #background_color_even => shift @_ || "#FFFFFF", #cell background color for even rows
     header_props   => $hdr_props, # see section HEADER ROW PROPERTIES

   );
 
 $font = $pdf->corefont('Times-Roman');
  $text->font($font,10);
  $text->translate(50,115); 
  $text->text("** Los resultados arrojados por el presente reporte son estimativos. Los mismos pueden presentar variaciones propias del sis-");
  $text->translate(53,100); 
  $text->text("tema, de los datos aportados, de las revisiones tarifarias y/o de las fluctuaciones climáticas, no asumiendo responsabilidad ni");
  $text->translate(53,85); 
  $text->text("obligacion por los resultados obtenidos");
  #$text->font('Times-Roman',10)
  $text->translate(513,60); 
  $text->text("Página: 2");
  $text->translate(50,60); 
  $text->text("Fecha:". $today);


 ####################PAGINA 3 ##################

  ######creación del grafico
 
  $page    = $pdf->openpage('3');
  $text    = $page->text();

  my $data = GD::Graph::Data->new([
      ["E-F","M-A","M-J","J-A","S-O","N-D"],
      [$consumo[0],$consumo[1],$consumo[2],$consumo[3],$consumo[4],$consumo[5]],
      [$generacion[0],$generacion[1],$generacion[2],$generacion[3],$generacion[4],$generacion[5] ],
  ]) or die GD::Graph::Data->error;
   
  my $graph = GD::Graph::mixed->new;
   
  $graph->set( types => ['bars','lines' ] );

  $graph->set( line_types => [1], dclrs => [ qw(red blue ) ],
  line_width=> 2  );
  $graph->set( 
      x_label         => 'Meses',
      y_label         => 'm3',
      interlaced    => 0,
      #title           => 'Producción vs Consumo',
   
      #y_max_value     => 12,
      #y_tick_number   => 12,
      #y_label_skip    => 3,
   
      #x_labels_vertical => 1,
   
      bar_spacing     => 2,
      #shadow_depth    => 4,
      shadowclr       => 'dred',
   
      transparent     => 0,
  ) or die $graph->error;
   
  $graph->plot($data) or die $graph->error;
   
  srand(time);
  my $nombreGrafico= int(rand(10000000000));
  $nombreGrafico .= ".png";
  #print $nombreGrafico;
  #exit;
  my $file = "$PNG"."$nombreGrafico";
  open(my $out, '>', $file) or die "Cannot open '$file' for write: $!";
  binmode $out;
  print $out $graph->gd->png;
  close $out;

  ##################### GRAFICO DE BARRAS ########################

  my $png =("$PNG"."$nombreGrafico");
  my $image = $pdf->image_png($png);
  my $gfx = $page->gfx;
  $gfx->image($image, 90, 350);
    
  $font = $pdf->corefont('Times-Bold');
  $text->font($font,12);
  $text->translate(60,700); 
  #$text->text("Gráfico Mixto de Consumo Total de la vivienda y Generación  de Agua Caliente Sanitaria");
   $text->text("Gráfico Mixto de Consumo Total de la Vivienda y Ahorro expresado en m3 equivalentes de gas");
   
     $font = $pdf->corefont('Times-Roman');
    $text->font($font,12);
  $text->translate(50,300); 
  $text->text("Las barras  indican consumo de Gas Natural Total  de la viviendia (cocción, calefacción y agua caliente),");
   $text->translate(50,280); 
  $text->text("mientras que la línea indica ahorro de gas (en m3 de gas) por generación de Agua Caliente Sanitaria.");
 
 
  $font = $pdf->corefont('Times-Roman');
  $text->font($font,10);
  $text->translate(50,115); 
  $text->text("** Los resultados arrojados por el presente reporte son estimativos. Los mismos pueden presentar variaciones propias del sis-");
  $text->translate(53,100); 
  $text->text("tema, de los datos aportados, de las revisiones tarifarias y/o de las fluctuaciones climáticas, no asumiendo responsabilidad ni");
  $text->translate(53,85); 
  $text->text("obligacion por los resultados obtenidos");
  #$text->font('Times-Roman',10)
  $text->translate(513,60); 
  $text->text("Página: 3");
  $text->translate(50,60); 
  $text->text("Fecha:". $today);


 ############nombre 
  my $nombreReporte= int(rand(10000000000));
  $nombreReporte.= ".pdf";
  #print $nombreReporte;

  $pdf->saveas("$REPORTE"."$nombreReporte");
  $pdf->end;

 return $nombreReporte; 
}


sub creaReporteEnvasado{


   my ($latitud,$longitud,$altitud,$tipoColector,$cantPersonas,$consumo,@genLit)= @_;
   #($latitud,$longitud,$altitud,$tipoColector,$cantPersonas,@genConsLit)= split(/,/,$datos);
  
  my @generacion;
  my @litros;
  for (my $i=0; $i<12;$i++){
    push @generacion, int($genLit[$i]);
  }
  for (my $i=12; $i<24;$i++){
    push @litros, int($genLit[$i]);
  }



  my $TEMPLATE = $path.'files/reportes/termico/headers/tresHojas.pdf';
  my $REPORTE= $path. 'files/reportes/termico/';
  my $PNG= $path.'files/reportes/termico/grafico/';
  my $pdf = PDF::API2->open($TEMPLATE);
  my $page    = $pdf->openpage('1');
  my $text    = $page->text();
  my $font    = $pdf->corefont('Times-Bold');

  $text->translate(213,680); 
  $text->font($font,12); 
  $text->text("Reporte de Generación de Agua Caliente Sanitaria");

  $text->translate(30,640); 
  $text->text("1. Parámetros de la Simulación");
  $font    = $pdf->corefont('Times-Roman');
  $text->font($font,12); 
  $text->translate(30,600); 
   $font    = $pdf->corefont('Times-Bold');
  $text->font($font,12); 
  $text->text("Sistema utilizado para el Agua Caliente Sanitaria: ");
  $font    = $pdf->corefont('Times-Roman');
  $text->font($font,12); 
  $text->text("  Gas Envasado");

  $font    = $pdf->corefont('Times-Bold');
  $text->font($font,12);
  $text->translate(30,550);
  $text->text("Lugar Geográfico:");

  $text->translate(150,550);
  $text->text("Latitud");

  $text->translate(270,550);
  $text->text("Longitud");

  $text->translate(390,550);
  $text->text("Altitud");

  $text->translate(510,550);
  $text->text("Pais");

  $text->translate(30,500);  #primero se mueve en la misma fila,distinta columna. Segundo mas cerca del 0 mas abajo en la hoja
  $text->text("Huso horario:");

  $text->font($pdf->corefont('Times-Roman'),12); 
  $text->translate(150,525);
  $text->text($latitud);

  $text->translate(280,525);
  $text->text($longitud);

  $text->translate(395,525);
  $text->text($altitud ." m");

  $text->translate(500,525);
  $text->text("Argentina");

  $text->translate(200,500);  #primero se mueve en la misma fila,distinta columna. Segundo mas cerca del 0 mas abajo en la hoja
  $text->text("UTC- 03:00");

  $text->font($pdf->corefont('Times-Bold'),12); 
  $text->translate(30,475);  
  $text->text("Tipo de Calefón Solar:");
  $text->translate(30,450);  
  $text->text("Orientación del Panel:");


  $font    = $pdf->corefont('Times-Roman');
  $text->font($font,12);
  $text->translate(200,475);
  if ($tipoColector==1){
  $text->text("Plano");
  }else {
   $text->text("Tubo Evacuado");
  }
  my $inclinacion = 30;
  $text->translate(200,450);  
  $text->text("Inclinación = ".$inclinacion."°"); 
  $text->translate(400,450);  
  $text->text("Azimut = 0° (orientación Norte)");
  $font = $pdf->corefont('Times-Bold');
  $text->font($font,12);
  $text->translate(30,425);  
  $text->text("Superficie del colector:");
  $text->translate(30,400);  
  $text->text("Cantidad de Personas residentes en la vivienda:");


  my $supCol=1;
  if ($cantPersonas==1 or $cantPersonas==1 ){
    $supCol= 1;
     $font = $pdf->corefont('Times-Roman');
    $text->font($font,12);
    $text->translate(300,425);  
    $text->text($supCol ." metro cuadrado");
  }else {
    $supCol= $cantPersonas * 0.5;
     $font = $pdf->corefont('Times-Roman');
    $text->font($font,12);
    $text->translate(300,425);  
    $text->text($supCol ." metros cuadrados");
  }



  my ($s, $min, $h, $d, $m, $y) = localtime();
  my $time = timelocal $s, $min, $h, $d, $m, $y;
  my $today= strftime "%d-%m-%Y", localtime $time; 
    $font    = $pdf->corefont('Times-Roman'); 
  $text->font($font,10);
  $text->translate(50,115); 
  $text->text("** Los resultados arrojados por el presente reporte son estimativos. Los mismos pueden presentar variaciones propias del sis-");
  $text->translate(53,100); 
  $text->text("tema, de los datos aportados, de las revisiones tarifarias y/o de las fluctuaciones climáticas, no asumiendo responsabilidad ni");
  $text->translate(53,85); 
  $text->text("obligacion por los resultados obtenidos");
  $text->translate(513,60); 
  $text->text("Página: 1");
  $text->translate(50,60); 
  $text->text("Fecha:". $today);

###########################2 hojas######


  $page    = $pdf->openpage('2');
  my $pdftable = new PDF::Table;
   $text    = $page->text();
  $font    = $pdf->corefont('Times-Roman');

  $text->translate(30,700);  #primero se mueve en la misma fila,distinta columna. Segundo mas cerca del 0 mas abajo en la hoja
  $font = $pdf->corefont('Times-Bold');
  $text->font($font,12);
  $text->text("2. Consumo Total de Gas Envasado y Ahorro de Agua Caliente Sanitaria (kg)");
  $font = $pdf->corefont('Times-Roman');
  $text->font($font,12);
  $text->translate(50,660);  
  $text->text("La siguiente tabla presenta un resumén mensual del consumo de gas envasado total y la generación de agua ");
  $text->translate(50,640); 
  $text->text("caliente sanitaria producida por el calefón solar. Ambos valores se encuentran expresados en kg. Es impor-");
   $text->translate(50,620); 
  $text->text("tante destacar que el gas envasado consumido integra: cocción de alimentos, calefacción  y  calentamiento");
   $text->translate(50,600); 
  $text->text("de agua. ");


# de agua.
####creacion de tabla

 my $hdr_props = 
  {
          # This param could be a pdf core font or user specified TTF.
          #  See PDF::API2 FONT METHODS for more information
          font       => $pdf->corefont("Times", -encoding => "utf-8"),
          font_size  => 14,
          font_color => '#141313', # #006666
          bg_color   => 'white',
         repeat     => 1,    # 1/0 eq On/Off  if the header row should be repeated to every new       page
      };
my $some_data =[
["Mes",
" Consumo Total [kg]",
" Ahorro de A.C.S [kg]",
" Generación de A.C.S [litros por día]"],
["Enero",
"         $consumo",
"         $generacion[0]",
"         $litros[0]"],
["Febrero",
"         $consumo",
"         $generacion[1]",
"         $litros[1]"],
["Marzo",
"         $consumo",
"         $generacion[2]",
"         $litros[2]"],
["Abril",
"         $consumo",
"         $generacion[3]",
"         $litros[3]"],
["Mayo",
"         $consumo",
"         $generacion[4]",
"         $litros[4]"],
["Junio",
"         $consumo",
"         $generacion[5]",
"         $litros[5]"],
["Julio",
"         $consumo",
"         $generacion[6]",
"         $litros[6]"],
["Agosto",
"         $consumo",
"         $generacion[7]",
"         $litros[7]"],
["Septiembre",
"         $consumo",
"         $generacion[8]",
"         $litros[8]"],
["Octubre",
"         $consumo",
"         $generacion[9]",
"         $litros[9]"],
["Noviembre",
"         $consumo",
"         $generacion[10]",
"         $litros[10]"],
["Diciembre",
"         $consumo",
"         $generacion[11]",
"         $litros[11]"],
];


 my $left_edge_of_table = 50;
   # build the table layout
  $pdftable->table(
  
    $pdf,
    $page,
    $some_data,
    x => $left_edge_of_table,
    w => 495,
    start_y => 580,
    next_y  => 50,
    start_h => 300,
    next_h  => 500,
    # some optional params
     padding => 4,
     #padding_right => 10,
     #background_color_odd  => shift @_ || "#FFFFFF",
     #background_color_even => shift @_ || "#FFFFFF", #cell background color for even rows
     header_props   => $hdr_props, # see section HEADER ROW PROPERTIES

   );
 
 $font = $pdf->corefont('Times-Roman');
  $text->font($font,10);
  $text->translate(50,115); 
  $text->text("** Los resultados arrojados por el presente reporte son estimativos. Los mismos pueden presentar variaciones propias del sis-");
  $text->translate(53,100); 
  $text->text("tema, de los datos aportados, de las revisiones tarifarias y/o de las fluctuaciones climáticas, no asumiendo responsabilidad ni");
  $text->translate(53,85); 
  $text->text("obligacion por los resultados obtenidos");
  #$text->font('Times-Roman',10)
  $text->translate(513,60); 
  $text->text("Página: 2");
  $text->translate(50,60); 
  $text->text("Fecha:". $today);


 ####################PAGINA 3 ##################

  ######creación del grafico
 
  $page    = $pdf->openpage('3');
  $text    = $page->text();

  my $data = GD::Graph::Data->new([
      ["E","F","M","A","M","J","J","A","S","O","N","D"],
      [$consumo,$consumo,$consumo,$consumo,$consumo,$consumo,$consumo,$consumo,$consumo,$consumo,$consumo,$consumo],
      [$generacion[0],$generacion[1],$generacion[2],$generacion[3],$generacion[4],$generacion[5],$generacion[6],$generacion[7],$generacion[8],$generacion[9],$generacion[10],$generacion[11]],
  ]) or die GD::Graph::Data->error;
   
  my $graph = GD::Graph::mixed->new;
   
  $graph->set( types => ['bars','lines' ] );

  $graph->set( line_types => [1], dclrs => [ qw(red blue ) ],
  line_width=> 2  );
  $graph->set( 
      x_label         => 'Meses',
      y_label         => 'kg',
      interlaced    => 0,
      #title           => 'Producción vs Consumo',
   
      #y_max_value     => 12,
      #y_tick_number   => 12,
      #y_label_skip    => 3,
   
      #x_labels_vertical => 1,
   
      bar_spacing     => 2,
      #shadow_depth    => 4,
      shadowclr       => 'dred',
   
      transparent     => 0,
  ) or die $graph->error;
   
  $graph->plot($data) or die $graph->error;
   
  srand(time);
  my $nombreGrafico= int(rand(10000000000));
  $nombreGrafico .= ".png";
  #print $nombreGrafico;
  #exit;
  my $file = "$PNG"."$nombreGrafico";
  open(my $out, '>', $file) or die "Cannot open '$file' for write: $!";
  binmode $out;
  print $out $graph->gd->png;
  close $out;

  ##################### GRAFICO DE BARRAS ########################

  my $png =("$PNG"."$nombreGrafico");
  my $image = $pdf->image_png($png);
  my $gfx = $page->gfx;
  $gfx->image($image, 90, 350);
    
  $font = $pdf->corefont('Times-Bold');
  $text->font($font,12);
  $text->translate(60,700); 
  $text->text("Gráfico Mixto de Consumo Total de la vivienda y Ahorro expresado en kg equivalentes de gas envasado");
     $font = $pdf->corefont('Times-Roman');
    $text->font($font,12);
  $text->translate(50,300); 
  $text->text("Las barras  indican consumo de Gas Envasado Total  de la viviendia (cocción, calefacción y agua caliente),  ");
   $text->translate(50,280); 
  $text->text("mientras que la línea indica ahorro (en kg) por generación de Agua Caliente Sanitaria.");
 
 
  $font = $pdf->corefont('Times-Roman');
  $text->font($font,10);
  $text->translate(50,115); 
  $text->text("** Los resultados arrojados por el presente reporte son estimativos. Los mismos pueden presentar variaciones propias del sis-");
  $text->translate(53,100); 
  $text->text("tema, de los datos aportados, de las revisiones tarifarias y/o de las fluctuaciones climáticas, no asumiendo responsabilidad ni");
  $text->translate(53,85); 
  $text->text("obligacion por los resultados obtenidos");
  #$text->font('Times-Roman',10)
  $text->translate(513,60); 
  $text->text("Página: 3");
  $text->translate(50,60); 
  $text->text("Fecha:". $today);


 ############nombre 
  srand(time);
  my $nombreReporte= int(rand(10000000000));
  $nombreReporte.= ".pdf";
  #print $nombreReporte;

  $pdf->saveas("$REPORTE"."$nombreReporte");
  $pdf->end;

 return $nombreReporte; 
}


sub creaReporteElectrico{


   my ($latitud,$longitud,$altitud,$tipoColector,$cantPersonas,@ConGenLit)= @_;
   #($latitud,$longitud,$altitud,$tipoColector,$cantPersonas,@genConsLit)= split(/,/,$datos);
  
  my @generacion;
  my @litros;
  my @consumo;
  
  for (my $i=0; $i<12;$i++){
    push @consumo, int($ConGenLit[$i]);
  }
  for (my $i=12; $i<24;$i++){
    push @generacion, int($ConGenLit[$i]);
  }
  for (my $i=24; $i<36;$i++){
    push @litros, int($ConGenLit[$i]);
  }


  my $TEMPLATE = $path.'files/reportes/termico/headers/tresHojas.pdf';
  my $REPORTE= $path. 'files/reportes/termico/';
  my $PNG= $path.'files/reportes/termico/grafico/';
 
  my $pdf = PDF::API2->open($TEMPLATE);
  my $page    = $pdf->openpage('1');
  my $text    = $page->text();
  my $font    = $pdf->corefont('Times-Bold');

  $text->translate(213,680); 
  $text->font($font,12); 
  $text->text("Reporte de Generación de Agua Caliente Sanitaria");

  $text->translate(30,640); 
  $text->text("1. Parámetros de la Simulación");
  $font    = $pdf->corefont('Times-Roman');
  $text->font($font,12); 
  $text->translate(30,600); 
   $font    = $pdf->corefont('Times-Bold');
  $text->font($font,12); 
  $text->text("Sistema utilizado para el Agua Caliente Sanitaria: ");
  $font    = $pdf->corefont('Times-Roman');
  $text->font($font,12); 
  $text->text("  Electricidad");

  $font    = $pdf->corefont('Times-Bold');
  $text->font($font,12);
  $text->translate(30,550);
  $text->text("Lugar Geográfico:");

  $text->translate(150,550);
  $text->text("Latitud");

  $text->translate(270,550);
  $text->text("Longitud");

  $text->translate(390,550);
  $text->text("Altitud");

  $text->translate(510,550);
  $text->text("Pais");

  $text->translate(30,500);  #primero se mueve en la misma fila,distinta columna. Segundo mas cerca del 0 mas abajo en la hoja
  $text->text("Huso horario:");

  $text->font($pdf->corefont('Times-Roman'),12); 
  $text->translate(150,525);
  $text->text($latitud);

  $text->translate(280,525);
  $text->text($longitud);

  $text->translate(395,525);
  $text->text($altitud ." m");

  $text->translate(500,525);
  $text->text("Argentina");

  $text->translate(200,500);  #primero se mueve en la misma fila,distinta columna. Segundo mas cerca del 0 mas abajo en la hoja
  $text->text("UTC- 03:00");

  $text->font($pdf->corefont('Times-Bold'),12); 
  $text->translate(30,475);  
  $text->text("Tipo de Calefón Solar:");
  $text->translate(30,450);  
  $text->text("Orientación de los Paneles:");


  $font    = $pdf->corefont('Times-Roman');
  $text->font($font,12);
  $text->translate(200,475);
  if ($tipoColector==1){
  $text->text("Plano");
  }else {
   $text->text("Tubo Evacuado");
  }
  my $inclinacion = 30;
  $text->translate(200,450);  
  $text->text("Inclinación = ".$inclinacion."°"); 
  $text->translate(400,450);  
  $text->text("Azimut = 0° (orientación Norte)");
  $font = $pdf->corefont('Times-Bold');
  $text->font($font,12);
  $text->translate(30,425);  
  $text->text("Superficie del colector:");
  $text->translate(30,400);  
  $text->text("Cantidad de Personas residentes en la vivienda:");


  my $supCol=1;
  if ($cantPersonas==1 or $cantPersonas==1 ){
    $supCol= 1;
     $font = $pdf->corefont('Times-Roman');
    $text->font($font,12);
    $text->translate(300,425);  
    $text->text($supCol ." metro cuadrado");
  }else {
    $supCol= $cantPersonas * 0.5;
     $font = $pdf->corefont('Times-Roman');
    $text->font($font,12);
    $text->translate(300,425);  
    $text->text($supCol ." metros cuadrados");
  }



  my ($s, $min, $h, $d, $m, $y) = localtime();
  my $time = timelocal $s, $min, $h, $d, $m, $y;
  my $today= strftime "%d-%m-%Y", localtime $time; 
    $font    = $pdf->corefont('Times-Roman'); 
  $text->font($font,10);
  $text->translate(50,115); 
  $text->text("** Los resultados arrojados por el presente reporte son estimativos. Los mismos pueden presentar variaciones propias del sis-");
  $text->translate(53,100); 
  $text->text("tema, de los datos aportados, de las revisiones tarifarias y/o de las fluctuaciones climáticas, no asumiendo responsabilidad ni");
  $text->translate(53,85); 
  $text->text("obligacion por los resultados obtenidos");
  $text->translate(513,60); 
  $text->text("Página: 1");
  $text->translate(50,60); 
  $text->text("Fecha:". $today);

###########################2 hojas######


  $page    = $pdf->openpage('2');
  my $pdftable = new PDF::Table;
   $text    = $page->text();
  $font    = $pdf->corefont('Times-Roman');

  $text->translate(30,700);  #primero se mueve en la misma fila,distinta columna. Segundo mas cerca del 0 mas abajo en la hoja
  $font = $pdf->corefont('Times-Bold');
  $text->font($font,12);
  $text->text("2. Consumo Total de Electricidad y Ahorro de Agua Caliente Sanitaria (kWh)");
  $font = $pdf->corefont('Times-Roman');
  $text->font($font,12);
  $text->translate(50,660);  
  $text->text("La siguiente tabla presenta un resumén mensual del consumo de electricidad total y la generación de agua ");
  $text->translate(50,640); 
  $text->text("caliente sanitaria producida por el calefón solar. Ambos valores se encuentran expresados en kWh. Es im-");
   $text->translate(50,620); 
  $text->text("portante destacar que la electricidad consumida integra: cocción de alimentos, calefacción  y  calentamiento");
   $text->translate(50,600); 
  $text->text("de agua. ");


# de agua.
####creacion de tabla

 my $hdr_props = 
  {
          # This param could be a pdf core font or user specified TTF.
          #  See PDF::API2 FONT METHODS for more information
          font       => $pdf->corefont("Times", -encoding => "utf-8"),
          font_size  => 14,
          font_color => '#141313', # #006666
          bg_color   => 'white',
         repeat     => 1,    # 1/0 eq On/Off  if the header row should be repeated to every new       page
      };
my $some_data =[
["Mes",
" Consumo Total [kWh]",
" Ahorro de A.C.S [kWh]",
" Generación de A.C.S [litros por día]"],
["Enero",
"         $consumo[0]",
"         $generacion[0]",
"         $litros[0]"],
["Febrero",
"         $consumo[1]",
"         $generacion[1]",
"         $litros[1]"],
["Marzo",
"         $consumo[2]",
"         $generacion[2]",
"         $litros[2]"],
["Abril",
"         $consumo[3]",
"         $generacion[3]",
"         $litros[3]"],
["Mayo",
"         $consumo[4]",
"         $generacion[4]",
"         $litros[4]"],
["Junio",
"         $consumo[5]",
"         $generacion[5]",
"         $litros[5]"],
["Julio",
"         $consumo[6]",
"         $generacion[6]",
"         $litros[6]"],
["Agosto",
"         $consumo[7]",
"         $generacion[7]",
"         $litros[7]"],
["Septiembre",
"         $consumo[8]",
"         $generacion[8]",
"         $litros[8]"],
["Octubre",
"         $consumo[9]",
"         $generacion[9]",
"         $litros[9]"],
["Noviembre",
"         $consumo[10]",
"         $generacion[10]",
"         $litros[10]"],
["Diciembre",
"         $consumo[11]",
"         $generacion[11]",
"         $litros[11]"],
];


 my $left_edge_of_table = 50;
   # build the table layout
  $pdftable->table(
  
    $pdf,
    $page,
    $some_data,
    x => $left_edge_of_table,
    w => 495,
    start_y => 580,
    next_y  => 50,
    start_h => 300,
    next_h  => 500,
    # some optional params
     padding => 4,
     #padding_right => 10,
     #background_color_odd  => shift @_ || "#FFFFFF",
     #background_color_even => shift @_ || "#FFFFFF", #cell background color for even rows
     header_props   => $hdr_props, # see section HEADER ROW PROPERTIES

   );
 
 $font = $pdf->corefont('Times-Roman');
  $text->font($font,10);
  $text->translate(50,115); 
  $text->text("** Los resultados arrojados por el presente reporte son estimativos. Los mismos pueden presentar variaciones propias del sis-");
  $text->translate(53,100); 
  $text->text("tema, de los datos aportados, de las revisiones tarifarias y/o de las fluctuaciones climáticas, no asumiendo responsabilidad ni");
  $text->translate(53,85); 
  $text->text("obligacion por los resultados obtenidos");
  #$text->font('Times-Roman',10)
  $text->translate(513,60); 
  $text->text("Página: 2");
  $text->translate(50,60); 
  $text->text("Fecha:". $today);


 ####################PAGINA 3 ##################

  ######creación del grafico
 
  $page    = $pdf->openpage('3');
  $text    = $page->text();

  my $data = GD::Graph::Data->new([
      ["E","F","M","A","M","J","J","A","S","O","N","D"],
      [$consumo[0],$consumo[1],$consumo[2],$consumo[3],$consumo[4],$consumo[5],$consumo[6],$consumo[7],$consumo[8],$consumo[9],$consumo[10],$consumo[11]],
      [$generacion[0],$generacion[1],$generacion[2],$generacion[3],$generacion[4],$generacion[5],$generacion[6],$generacion[7],$generacion[8],$generacion[9],$generacion[10],$generacion[11]],
  ]) or die GD::Graph::Data->error;
   
  my $graph = GD::Graph::mixed->new;
   
  $graph->set( types => ['bars','lines' ] );

  $graph->set( line_types => [1], dclrs => [ qw(red blue ) ],
  line_width=> 2  );
  $graph->set( 
      x_label         => 'Meses',
      y_label         => 'kWh',
      interlaced    => 0,
      #title           => 'Producción vs Consumo',
   
      #y_max_value     => 12,
      #y_tick_number   => 12,
      #y_label_skip    => 3,
   
      #x_labels_vertical => 1,
   
      bar_spacing     => 2,
      #shadow_depth    => 4,
      shadowclr       => 'dred',
   
      transparent     => 0,
  ) or die $graph->error;
   
  $graph->plot($data) or die $graph->error;
   
  srand(time);
  my $nombreGrafico= int(rand(10000000000));
  $nombreGrafico .= ".png";
  #print $nombreGrafico;
  #exit;
  my $file = "$PNG"."$nombreGrafico";
  open(my $out, '>', $file) or die "Cannot open '$file' for write: $!";
  binmode $out;
  print $out $graph->gd->png;
  close $out;

  ##################### GRAFICO DE BARRAS ########################

  my $png =("$PNG"."$nombreGrafico");
  my $image = $pdf->image_png($png);
  my $gfx = $page->gfx;
  $gfx->image($image, 90, 350);
    
  $font = $pdf->corefont('Times-Bold');
  $text->font($font,12);
  $text->translate(60,700); 
  $text->text("Gráfico Mixto de Consumo Total de la vivienda y Ahorro en kWh equivalentes de electricidad");
     $font = $pdf->corefont('Times-Roman');
    $text->font($font,12);
  $text->translate(50,300); 
  $text->text("Las barras  indican consumo de Electricidad  de la vivienda (cocción, calefacción y agua caliente),  ");
   $text->translate(50,280); 
  $text->text("mientras que la línea indica Ahorro (en kWh) por generación de Agua Caliente Sanitaria.");
 
 
  $font = $pdf->corefont('Times-Roman');
  $text->font($font,10);
  $text->translate(50,115); 
  $text->text("** Los resultados arrojados por el presente reporte son estimativos. Los mismos pueden presentar variaciones propias del sis-");
  $text->translate(53,100); 
  $text->text("tema, de los datos aportados, de las revisiones tarifarias y/o de las fluctuaciones climáticas, no asumiendo responsabilidad ni");
  $text->translate(53,85); 
  $text->text("obligacion por los resultados obtenidos");
  #$text->font('Times-Roman',10)
  $text->translate(513,60); 
  $text->text("Página: 3");
  $text->translate(50,60); 
  $text->text("Fecha:". $today);


 ############nombre 
  my $nombreReporte= int(rand(10000000000));
  $nombreReporte.= ".pdf";
  #print $nombreReporte;

  $pdf->saveas("$REPORTE"."$nombreReporte");
  $pdf->end;

  return $nombreReporte; 

}

sub creaReporteSinInstalacion{


   my ($latitud,$longitud,$altitud,$tipoColector,$cantPersonas,@litros)= @_;
   #($latitud,$longitud,$altitud,$tipoColector,$cantPersonas,@genConsLit)= split(/,/,$datos);
  
  for (my $i=0; $i<12;$i++){
    $litros[$i]= int($litros[$i]);
  }

  my $TEMPLATE = $path.'files/reportes/termico/headers/dosHojas.pdf';
  my $REPORTE= $path. 'files/reportes/termico/';
  my $PNG= $path.'files/reportes/termico/grafico/';
 
 my $pdf = PDF::API2->open($TEMPLATE);
  my $page    = $pdf->openpage('1');
  my $text    = $page->text();
  my $font    = $pdf->corefont('Times-Bold');

  $text->translate(213,680); 
  $text->font($font,12); 
  $text->text("Reporte de Generación de Agua Caliente Sanitaria");

  $text->translate(30,640); 
  $text->text("1. Parámetros de la Simulación");
  $font    = $pdf->corefont('Times-Roman');
  $text->font($font,12); 
  $text->translate(30,600); 
   $font    = $pdf->corefont('Times-Bold');
  $text->font($font,12); 
  $text->text("Sin Instalación para Agua Caliente Sanitaria: ");
  $font    = $pdf->corefont('Times-Roman');

  $font    = $pdf->corefont('Times-Bold');
  $text->font($font,12);
  $text->translate(30,550);
  $text->text("Lugar Geográfico:");

  $text->translate(150,550);
  $text->text("Latitud");

  $text->translate(270,550);
  $text->text("Longitud");

  $text->translate(390,550);
  $text->text("Altitud");

  $text->translate(510,550);
  $text->text("Pais");

  $text->translate(30,500);  #primero se mueve en la misma fila,distinta columna. Segundo mas cerca del 0 mas abajo en la hoja
  $text->text("Huso horario:");

  $text->font($pdf->corefont('Times-Roman'),12); 
  $text->translate(150,525);
  $text->text($latitud);

  $text->translate(280,525);
  $text->text($longitud);

  $text->translate(395,525);
  $text->text($altitud." m");

  $text->translate(500,525);
  $text->text("Argentina");

  $text->translate(200,500);  #primero se mueve en la misma fila,distinta columna. Segundo mas cerca del 0 mas abajo en la hoja
  $text->text("UTC- 03:00");

  $text->font($pdf->corefont('Times-Bold'),12); 
  $text->translate(30,475);  
  $text->text("Tipo de Calefón Solar:");
  $text->translate(30,450);  
  $text->text("Orientación de los Paneles:");


  $font    = $pdf->corefont('Times-Roman');
  $text->font($font,12);
  $text->translate(200,475);
  if ($tipoColector==1){
  $text->text("Plano");
  }else {
   $text->text("Tubo Evacuado");
  }
  my $inclinacion = 30;
  $text->translate(200,450);  
  $text->text("Inclinación = ".$inclinacion."°"); 
  $text->translate(400,450);  
  $text->text("Azimut = 0° (orientación Norte)");
  $font = $pdf->corefont('Times-Bold');
  $text->font($font,12);
  $text->translate(30,425);  
  $text->text("Superficie del colector:");
  $text->translate(30,400);  
  $text->text("Cantidad de Personas residentes en la vivienda:");

  my $supCol=1;
  if ($cantPersonas==1 or $cantPersonas==1 ){
    $supCol= 1;
  }else {
    $supCol= $cantPersonas * 0.5;
  }
  $font = $pdf->corefont('Times-Roman');
  $text->font($font,12);
  $text->translate(300,425);  
  $text->text($supCol ." metros cuadrados");
  $text->translate(300,400);  
  $text->text($cantPersonas. " personas");



  my ($s, $min, $h, $d, $m, $y) = localtime();
  my $time = timelocal $s, $min, $h, $d, $m, $y;
  my $today= strftime "%d-%m-%Y", localtime $time; 
    $font    = $pdf->corefont('Times-Roman'); 
  $text->font($font,10);
  $text->translate(50,115); 
  $text->text("** Los resultados arrojados por el presente reporte son estimativos. Los mismos pueden presentar variaciones propias del sis-");
  $text->translate(53,100); 
  $text->text("tema, de los datos aportados, de las revisiones tarifarias y/o de las fluctuaciones climáticas, no asumiendo responsabilidad ni");
  $text->translate(53,85); 
  $text->text("obligacion por los resultados obtenidos");
  $text->translate(513,60); 
  $text->text("Página: 1");
  $text->translate(50,60); 
  $text->text("Fecha:". $today);

###########################2 hojas######


  $page    = $pdf->openpage('2');
  my $pdftable = new PDF::Table;
   $text    = $page->text();
  $font    = $pdf->corefont('Times-Roman');

  $text->translate(30,700);  #primero se mueve en la misma fila,distinta columna. Segundo mas cerca del 0 mas abajo en la hoja
  $font = $pdf->corefont('Times-Bold');
  $text->font($font,12);
  $text->text("2. Generación de Agua Caliente Sanitaria (litros)");
  $font = $pdf->corefont('Times-Roman');
  $text->font($font,12);
  $text->translate(50,660);  
  $text->text("La siguiente tabla presenta un resumén mensual  de la cantidad de litros por día de Agua Caliente Sani- ");
  $text->translate(50,640); 
  $text->text("taria para consumo.");
   $text->translate(50,620); 



# de agua.
####creacion de tabla

 my $hdr_props = 
  {
          # This param could be a pdf core font or user specified TTF.
          #  See PDF::API2 FONT METHODS for more information
          font       => $pdf->corefont("Times", -encoding => "utf-8"),
          font_size  => 14,
          font_color => '#141313', # #006666
          bg_color   => 'white',
         repeat     => 1,    # 1/0 eq On/Off  if the header row should be repeated to every new       page
      };
my $some_data =[
["Mes",
" Generación de A.C.S [litros por día]"],
["Enero",
"         $litros[0]"],
["Febrero",
"         $litros[1]"],
["Marzo",
"         $litros[2]"],
["Abril",
"         $litros[3]"],
["Mayo",

"         $litros[4]"],
["Junio",
"         $litros[5]"],
["Julio",
"         $litros[6]"],
["Agosto",
"         $litros[7]"],
["Septiembre",
"         $litros[8]"],
["Octubre",
"         $litros[9]"],
["Noviembre",
"         $litros[10]"],
["Diciembre",
"         $litros[11]"],
];


 my $left_edge_of_table = 50;
   # build the table layout
  $pdftable->table(
  
    $pdf,
    $page,
    $some_data,
    x => $left_edge_of_table,
    w => 495,
    start_y => 580,
    next_y  => 50,
    start_h => 300,
    next_h  => 500,
    # some optional params
     padding => 4,
     #padding_right => 10,
     #background_color_odd  => shift @_ || "#FFFFFF",
     #background_color_even => shift @_ || "#FFFFFF", #cell background color for even rows
     header_props   => $hdr_props, # see section HEADER ROW PROPERTIES

   );
 
 $font = $pdf->corefont('Times-Roman');
  $text->font($font,10);
  $text->translate(50,115); 
  $text->text("** Los resultados arrojados por el presente reporte son estimativos. Los mismos pueden presentar variaciones propias del sis-");
  $text->translate(53,100); 
  $text->text("tema, de los datos aportados, de las revisiones tarifarias y/o de las fluctuaciones climáticas, no asumiendo responsabilidad ni");
  $text->translate(53,85); 
  $text->text("obligacion por los resultados obtenidos");
  #$text->font('Times-Roman',10)
  $text->translate(513,60); 
  $text->text("Página: 2");
  $text->translate(50,60); 
  $text->text("Fecha:". $today);


 ####################PAGINA 3 ##################


 ############nombre 
 srand(time);
  my $nombreReporte= int(rand(10000000000));
  $nombreReporte.= ".pdf";
  #print $nombreReporte;

  $pdf->saveas("$REPORTE"."$nombreReporte");
  $pdf->end;

  return $nombreReporte; 

}
1;