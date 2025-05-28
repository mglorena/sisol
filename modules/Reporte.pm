package Reporte;
use strict;
use warnings;
use PDF::API2;
use PDF::Table;
use GD::Graph::mixed;
use GD::Graph::Data;
use PDF::Reuse;
use utf8;
use Time::Local;
use POSIX qw/strftime/;
use Data::Dumper;
use Switch;
use Conf;


my $path=$Conf::reportesURL;
sub creaReporte{
  
  my ($latitud,$longitud,$altitud,$conexion,$capacidad,$inclinacion,$tipoMon,$eficiencia,$perdida,$tipoUsuario,@genYcons)= @_;
  #precrio promocional de energia producida por fotovoltaico
  my $precioPromocional= 5.6687;
  my @generacion;
  my @consumo;

  for (my $i=0; $i<12;$i++){
    push @generacion, $genYcons[$i];
  }
  for (my $i=12; $i<24;$i++){
    push @consumo, $genYcons[$i];
  }
  #$tipoMont=$tipoMont +0;
  $tipoMon= int($tipoMon);
  my $tipoMontaje;
  if ($tipoMon==3) {
    $tipoMontaje= "Roof Top";
  } else{
    $tipoMontaje= "Stand alone";
  }

  my $TEMPLATE = $path.'files/reportes/fotovoltaico/headers/cincoHojasB.pdf';
  my $REPORTE= $path. 'files/reportes/fotovoltaico/';
  my $PNG= $path.'files/reportes/fotovoltaico/graficos/';
  my $pdf = PDF::API2->open($TEMPLATE);
  my $page    = $pdf->openpage('1');
  my $text    = $page->text();
  my $font    = $pdf->corefont('Times-Bold');

  $text->translate(213,660); 
  $text->font($font,12); 
  $text->text("Reporte de Generación Eléctrica Fotovoltaica");

  $text->translate(30,640); 
  $text->text("1. Parámetros de la Simulación");
  $font    = $pdf->corefont('Times-Roman');

    $text->translate(30,600); 
    $text->text("Sistema Conectado a la Red");
 

  #primero se mueve en la misma fila,distinta columna. Segundo mas cerca del 0 mas abajo en la hoja

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
  $text->text("Capacidad a Instalar:");
  $text->translate(30,450);  
  $text->text("Orientación de los Paneles:");
  #$text->translate(30,350);  
  #$text->text("Necesidad de los usuarios:");
  $text->translate(30,425);  
  $text->text("Tipo de montaje:");
  $text->translate(30,400);  
  $text->text("Eficiencia del Inversor (%):");
  $text->translate(30,375);  
  $text->text("Factor de Perdida (%):");
  
  $text->translate(30,350);  
  $text->text("Tipo de Usuario (Según clasificación EDESa):");

  #respuestas 
  $font    = $pdf->corefont('Times-Roman');
  $text->font($font,12);
  $text->translate(200,450);  
  $text->text("Inclinación = ".$inclinacion."° *"); 
  $text->translate(400,450);  
  $text->text("Azimut = 0° (orientación Norte)");
  $text->translate(200,475);
  $text->text($capacidad . " Kw");
  $text->translate(200,425);   
  $text->text($tipoMontaje); 
  $eficiencia= $eficiencia *100;
  $text->translate(200,400);  
  $text->text($eficiencia. " %");
  $perdida= $perdida*100;
  $text->translate(200,375);  
  $text->text($perdida ." %");
  my $nombreUsuario=calculaNombreUsuario($tipoUsuario);

  $text->translate(280,350);  
  $text->text("$nombreUsuario");

  $font = $pdf->corefont('Times-Roman');
  $text->font($font,10);
  $text->translate(50,130);
  $text->text("*  El rango óptimo de inclinación para la provincia de Salta es  [latitud - 10°,latitud + 10°].");
  $font = $pdf->corefont('Times-Roman');
  $text->font($font,10);
  $text->translate(50,115); 
  $text->text("** Los resultados arrojados por el presente reporte son estimativos. Los mismos pueden presentar variaciones propias del sis-");
  $text->translate(53,100); 
  $text->text("tema, de los datos aportados, de las revisiones tarifarias y/o de las fluctuaciones climáticas, no asumiendo responsabilidad ni");
  $text->translate(53,85); 
  $text->text("obligacion por los resultados obtenidos");
  my ($s, $min, $h, $d, $m, $y) = localtime();
  my $time = timelocal $s, $min, $h, $d, $m, $y;
  my $today= strftime "%d-%m-%Y", localtime $time;
  #$text->font('Times-Roman',10)
  $text->translate(513,60); 
  $text->text("Página: 1");
  $text->translate(50,60); 
  $text->text("Fecha:". $today);
    
  #$text->translate(50,55); 
  #$text->text($today);
   
 
#$pdf->saveas($RESULT_PDF);
 # $pdf->end;

####TABLA

  my $pdftable = new PDF::Table;
  $page    = $pdf->openpage('2');
  #$page    = $pdf->page();
  $text    = $page->text();
  $font    = $pdf->corefont('Times-Roman');

  $text->translate(30,700);  #primero se mueve en la misma fila,distinta columna. Segundo mas cerca del 0 mas abajo en la hoja
  $font = $pdf->corefont('Times-Bold');
  $text->font($font,12);
  $text->text("2. Consumo y Generación de energía eléctrica mensual");
  $font = $pdf->corefont('Times-Roman');
  $text->font($font,12);
  $text->translate(50,660);  
  $text->text("La siguiente tabla presenta un resumén mensual del consumo eléctrico y la generación eléctrica");
  $text->translate(50,640); 
  $text->text("producida por la instalación fotovoltaica. Ambos valores se encuentran expresados en kWh:");

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
"         C.E[kWh]",
"         G.E [kWh]"],
["Enero",
"         $consumo[0]",
"         $generacion[0]"],
["Febrero",
"         $consumo[1]",
"         $generacion[1]"],
["Marzo",
"         $consumo[2]",
"         $generacion[2]"],
["Abril",
"         $consumo[3]",
"         $generacion[3]"],
["Mayo",
"         $consumo[4]",
"         $generacion[4]"],
["Junio",
"         $consumo[5]",
"         $generacion[5]"],
["Julio",
"         $consumo[6]",
"         $generacion[6]"],
["Agosto",
"         $consumo[7]",
"         $generacion[7]"],
["Septiembre",
"         $consumo[8]",
"         $generacion[8]"],
["Octubre",
"         $consumo[9]",
"         $generacion[9]"],
["Noviembre",
"         $consumo[10]",
"         $generacion[10]"],
["Diciembre",
"         $consumo[11]",
"         $generacion[11]"],
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
    next_y  => 560,
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
  $text->font($font,12);
  $text->translate(50,250); 
  $text->text("C.E: Consumo eléctrico mensual, expresado en kWh.");
  $text->translate(50,230); 
  $text->text("G.E: Generación eléctrica fotovoltaica mensual, expresado en kWh.");
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


############### 3 hoja con gráfico
  $page    = $pdf->openpage('3');
  $text    = $page->text();

######creación del grafico
  my $data = GD::Graph::Data->new([
      ["E","F","M","A","M","J","J", "A", "S", "O", "N","D"],
      [ $consumo[0], $consumo[1]  , $consumo[2],$consumo[3], $consumo[4],  $consumo[5], $consumo[6], $consumo[7],     
       $consumo[8],$consumo[9],$consumo[10],$consumo[11]],
      [ $generacion[0]  ,  $generacion[1],$generacion[2],$generacion[3],$generacion[4],$generacion[5],$generacion[6],
          $generacion[7], $generacion[8],     $generacion[9], $generacion[10],$generacion[11]],

  ]) or die GD::Graph::Data->error;
   
   
  my $graph = GD::Graph::mixed->new;
     
  $graph->set( types => ['bars','lines' ] );

  $graph->set( line_types => [1], dclrs => [ qw(red blue ) ],
  line_width=> 2  );

  $graph->set( 
      x_label         => 'Meses',
      y_label         => 'KWh',
      interlaced    => 0,
      #title           => 'Producción vs Consumo',
   
      #y_max_value     => 12,
      #y_tick_number   => 12,
      #y_label_skip    => 3,
   
      #x_labels_vertical => 1,
   
      bar_spacing     => 2,
      shadow_depth    => 1,
      shadowclr       => 'dred',
   
      transparent     => 0,
  ) or die $graph->error;
   
  $graph->plot($data) or die $graph->error;
   
  srand(time);
  my $nombreGrafico= int(rand(10000000000));
  $nombreGrafico .= ".png";
 
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
  $text->translate(180,700); 
  $text->text("Gráfico Mixto de Consumo y Generación Eléctrica");
     $font = $pdf->corefont('Times-Roman');
    $text->font($font,12);
  $text->translate(50,300); 
  $text->text("Las barras indican consumo eléctrico, mientras que la linea indica generación eléctrica fotovoltaica.");
 
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


############### 4 hoja 

  $page    = $pdf->openpage('4');
  $pdftable = new PDF::Table;
  my $genAnual= 0;
  map { $genAnual += $_ } @generacion;
  $genAnual= int($genAnual);
  
  my $consAnual=0;
  map { $consAnual += $_ } @consumo;
  $consAnual = int($consAnual);
  my $balanceAnual= int($genAnual - $consAnual);

  $hdr_props = 
  {
          # This param could be a pdf core font or user specified TTF.
          #  See PDF::API2 FONT METHODS for more information
          font       => $pdf->corefont("Times", -encoding => "utf-8"),
          font_size  => 14,
          font_color => '#141313', # #006666
          bg_color   => 'white',
         repeat     => 1,    # 1/0 eq On/Off  if the header row should be repeated to every new       page
      };
    $some_data =[["Energía Anual Consumida [kWh]",
  "Energía Anual Generada [kWh]",
  " Balance(Generación – Consumo) [kWh]"],
  ["$consAnual",
  "$genAnual ",
   $balanceAnual]];

#Energía Anual Consumida

  $left_edge_of_table = 50;
   # build the table layout
  $pdftable->table(  
    $pdf,
    $page,
    $some_data,
    x => $left_edge_of_table,
    w => 495,
    start_y => 600,
    next_y  => 570,
    start_h => 300,
    next_h  => 500,
    # some optional params
     padding => 5,
     padding_right => 10,
     #background_color_odd  => shift @_ || "#FFFFFF",
     #background_color_even => shift @_ || "#FFFFFF", #cell background color for even rows
     header_props   => $hdr_props, # see section HEADER ROW PROPERTIES

   );
 
    $text    = $page->text();
    $font = $pdf->corefont('Times-Bold');
    $text->font($font,12);
    $text->translate(30,700);  
    $font = $pdf->corefont('Times-Roman');
    $text->text("3. Estimaciones en el marco de la Ley 7824 de Balance Neto. Decreto Reglamentario 448/17");
    $font = $pdf->corefont("Times-Roman");
    $text->font($font,12);
    $text->translate(50,660); 
    $text->text("La Ley 7.824: Esta ley tiene por objeto el establecimiento de las condiciones administrativas, técnicas");
    $text->translate(50,640); 
    $text->text("y económicas para la aplicación de la modalidad de suministro de energía eléctrica con Balance Neto.");
    $text->font($font,12);
  
  
    my $ingAnualPromo;
    my $precioElec= calculaTipoUsuario($tipoUsuario,@consumo);
    ;
    my $ahoAn= 0;
    my $ingAnual=0;
   
    $ingAnualPromo= int($genAnual * $precioPromocional) ;
    $ahoAn= int($genAnual *$precioElec);
    my $pesos= $ingAnualPromo;
    my $balance= int($genAnual - $consAnual);
 
    $text->translate(50,500);
    $text->text("En el marco del actual decreto reglamentario, durante los primeros dos (2) años, y como medida de fo-");
    $text->translate(50,480);
    $text->text("mento, se abonará al Usuario el total de la energía generada al valor de la tarifa  promocional. Por ello,");
    $text->translate(50,460);
    $text->text("el 1° y 2° año el Usuario, recibiría anualmente un total aprox. de \$ $pesos según cuadro tarifario vigente.");
    $text->translate(50,430);
    $text->text("A partir del 3° (tercer) año, se efectuarán  las compensaciones de energía y el saldo será facturado a la");
    $text->translate(50,410);
    $text->text("tarifa  que corresponda. Si se registran excedentes de  energía eléctrica generada, solo para  éstos exce-");
    $text->translate(50,390);
    $text->text("dentes se pagará la tarifa promocional.");

  if($balanceAnual <0){
      $text->translate(50,360);
      $text->text("Para la simulación realizada, no se registran excedentes. A partir del 3° año (y los siguientes), se gene-");
      $text->translate(50,340);
      $text->text("raría  un  ahorro anual de $genAnual kWh, lo que significa un monto anual aprox. de \$$ahoAn según tipo de");
      $text->translate(50,320);
      $text->text("usuario y cuadro tarifario vigente.");
      $pdftable = new PDF::Table;
     $hdr_props = 
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
    ["Año",
    "Ingresos por medida de fomento (\$)",
    "Ahorro por la Energía Generada (\$)", 
    "Ingresos por excedentes de Energía Eléctrica (\$)"],
    ["1er",
    int($ingAnualPromo),
    "     N/C",
    "     N/C"],
    ["2do",
    int($ingAnualPromo),
    "     N/C", 
    "     N/C"],
    ["3er y siguientes",
    "      -",
    int($ahoAn), 
    "No hay excedentes"],
    ];

    $left_edge_of_table = 50;
       # build the table layout
    $pdftable->table(
      
      $pdf,
      $page,
      $some_data,
          x => $left_edge_of_table,
          w => 495,
          start_y => 300,
          next_y  => 280,
          start_h => 300,
          next_h  => 500,
          # some optional params
           padding => 5,
           padding_right => 10,
           #background_color_odd  => shift @_ || "#FFFFFF",
           #background_color_even => shift @_ || "#FFFFFF", #cell background color for even rows
           header_props   => $hdr_props, # see section HEADER ROW PROPERTIES
    );
  }  
  else {

    $ahoAn= int($consAnual * calculaTipoUsuario($tipoUsuario,@consumo));
    my $ingAnualPromo= int($genAnual *$precioPromocional);
    my $excAnual= int($balance * $precioPromocional);
    #my $= $genAnual * calculaTipoUsuario(@consumo);

    $text->translate(50,370);
    $text->text("Para la simulación realizada, se registran $balance kWh de excedentes anuales. A partir del 3° año (y los si-");
    $text->translate(50,350);
    $text->text("guientes) se generaría  un ahorro anual aproximado de $consAnual kWh, lo que significa un monto anual aprox");
    $text->translate(50,330);
    $text->text("de \$$ahoAn según tipo de usuario y cuadro tarifario vigente. ");
    $pdftable = new PDF::Table;
    $hdr_props = 
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
    ["Año",
    "Ingresos por medida de fomento (\$)",
    "Ahorro por la Energía Generada (\$)", 
    "Ingresos por excedentes de Energía Eléctrica (\$)"],
    ["1er",
    "$ingAnualPromo ",
    "     N/C",
    "     N/C"],
    ["2er",
    "$ingAnualPromo ",
    "     N/C",
    "     N/C"],
    ["3er y siguientes",
    "     N/C",
    "$ahoAn ", 
    "$excAnual"],
    ];

      $left_edge_of_table = 50;
       # build the table layout
      $pdftable->table(
      
        $pdf,
        $page,
        $some_data,
        x => $left_edge_of_table,
        w => 495,
        start_y => 300,
        next_y  => 280,
        start_h => 300,
        next_h  => 500,
        # some optional params
         padding => 5,
         padding_right => 10,
         #background_color_odd  => shift @_ || "#FFFFFF",
         #background_color_even => shift @_ || "#FFFFFF", #cell background color for even rows
         header_props   => $hdr_props, # see section HEADER ROW PROPERTIES

       );
  }

 $font = $pdf->corefont('Times-Roman');
  $text->font($font,12);
  $text->translate(50,150);
   $text->text("N/C: No corresponde");
  #  
#Para la simulación realizada, no se registran excedentes. A partir del 3° año (y los siguientes), se generaría un ahorro anual de 750 kWh, lo que significa un monto anual de $       1.785       según tipo de usuario y cuadro tarifario vigente.
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
  $text->text("Página: 4");
  $text->translate(50,60); 
  $text->text("Fecha:". $today);

##################5 pdf 

  $page= $pdf->openpage('5');
  $text = $page->text();
  $font = $pdf->corefont('Times-Bold');
  $text= $page->text();

  $text->font($font,12);
  $text->translate(30,700);  
  $font = $pdf->corefont('Times-Roman');
  $text->text("4. Supuestos");
  $font = $pdf->corefont("Times-Roman");
  $text->font($font,12);
  $text->translate(50,670); 
  $text->text("Las estimaciones realizadas se basan en los siguientes supuestos:");
  $text->font($font,12);
  $text->translate(50,640); 
  $font = $pdf->corefont('Times-Bold');
  $text->font($font,12);
  $text->text("1. ");
  $font = $pdf->corefont('Times-Roman');
  $text->font($font,12);
  $text->text(" El consumo anual de electricidad se mantiene constante. Las estimaciones toman como referencia  los");
  $text->translate(50,620); 
  $text->text("datos de consumo mensual ingresados por el usuario.");
  $font = $pdf->corefont('Times-Bold');
  $text->font($font,12);
  $text->translate(50,590); 
  $text->text("2. ");
  $font = $pdf->corefont('Times-Roman');
  $text->font($font,12);
  $text->text(" Las estimaciones se realizan en base a las tarifas vigentes al momento de la consulta.");
 
  $text->font($font,10);
  $text->translate(50,115); 
  $text->text("** Los resultados arrojados por el presente reporte son estimativos. Los mismos pueden presentar variaciones propias del sis-");
  $text->translate(53,100); 
  $text->text("tema, de los datos aportados, de las revisiones tarifarias y/o de las fluctuaciones climáticas, no asumiendo responsabilidad ni");
  $text->translate(53,85); 
  $text->text("obligacion por los resultados obtenidos");
  $text->translate(513,60); 
  $text->text("Página: 5");
  $text->translate(50,60); 
  $text->text("Fecha:". $today);
  my $nombreReporte= int(rand(10000000000));
  $nombreReporte.= ".pdf";

  $pdf->saveas("$REPORTE"."$nombreReporte");
  $pdf->end;

  return $nombreReporte;

}

sub creaReporteSinConexion{

  my ($latitud,$longitud,$altitud,$conexion,$capacidad,$inclinacion,$tipoMon,$eficiencia,$perdida,$tipoUsuario,@genYcons)= @_;

  my @generacion;
  my @consumo;

  for (my $i=0; $i<12;$i++){
    push @generacion, $genYcons[$i];
  }
  for (my $i=12; $i<24;$i++){
    push @consumo, $genYcons[$i];
  }
   
  my $tipoMontaje;
  if ($tipoMon==1) {
    $tipoMontaje= "Roof Top";
  } else{
    $tipoMontaje= "Stand alone";
  }

  my $TEMPLATE = $path.'files/reportes/fotovoltaico/headers/tresHojas.pdf';
  my $REPORTE= $path. 'files/reportes/fotovoltaico/';
  my $PNG= $path.'files/reportes/fotovoltaico/graficos/';

  my $pdf = PDF::API2->open($TEMPLATE);
  my $page    = $pdf->openpage('1');
  my $text    = $page->text();
  my $font    = $pdf->corefont('Times-Bold');

  $text->translate(213,660); 
  $text->font($font,12); 
  $text->text("Reporte de Generación Eléctrica Fotovoltaica");

  $text->translate(30,640); 
  $text->text("1. Parámetros de la Simulación");
  $font    = $pdf->corefont('Times-Roman');

 
    $text->translate(30,600); 
    $text->text("Sistema Aislado");
  

  #primero se mueve en la misma fila,distinta columna. Segundo mas cerca del 0 mas abajo en la hoja

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
  $text->text("Capacidad a Instalar:");
  $text->translate(30,450);  
  $text->text("Orientación de los Paneles:");
  #$text->translate(30,350);  
  #$text->text("Necesidad de los usuarios:");
  $text->translate(30,425);  
  $text->text("Tipo de montaje:");
  $text->translate(30,400);  
  $text->text("Eficiencia del Inversor (%):");
  $text->translate(30,375);  
  $text->text("Factor de Perdida (%):");

  #respuestas 
  $font    = $pdf->corefont('Times-Roman');
  $text->font($font,12);
  $text->translate(200,450);  
  $text->text("Inclinación = ".$inclinacion."° *"); 
  $text->translate(400,450);  
  $text->text("Azimut = 0° (orientación Norte)");
  $text->translate(200,475);
  $text->text($capacidad . " kw");
  $text->translate(200,425);  
 
  $text->text($tipoMontaje); 
  $text->translate(200,400);  
  $text->text($eficiencia. " %");
  $text->translate(200,375);  
  $text->text($perdida ." %");


  $font = $pdf->corefont('Times-Roman');
  $text->font($font,10);
  $text->translate(50,130);
  $text->text("*  El rango óptimo de inclinación para la provincia de Salta es  [latitud - 10°,latitud + 10°].");
  $font = $pdf->corefont('Times-Roman');
  $text->font($font,10);
  $font = $pdf->corefont('Times-Roman');
  $text->font($font,10);
  $text->translate(50,115); 
  $text->text("** Los resultados arrojados por el presente reporte son estimativos. Los mismos pueden presentar variaciones propias del sis-");
  $text->translate(53,100); 
  $text->text("tema, de los datos aportados, de las revisiones tarifarias y/o de las fluctuaciones climáticas, no asumiendo responsabilidad ni");
  $text->translate(53,85); 
  $text->text("obligacion por los resultados obtenidos");
  my ($s, $min, $h, $d, $m, $y) = localtime();
  my $time = timelocal $s, $min, $h, $d, $m, $y;
  my $today= strftime "%d-%m-%Y", localtime $time;
  #$text->font('Times-Roman',10)
  $text->translate(513,60); 
  $text->text("Página: 1");
  $text->translate(50,60); 
  $text->text("Fecha:". $today);
    
  #$text->translate(50,55); 
  #$text->text($today);
   
 
#$pdf->saveas($RESULT_PDF);
 # $pdf->end;

####TABLA

  my $pdftable = new PDF::Table;
  $page    = $pdf->openpage('2');
  #$page    = $pdf->page();
  $text    = $page->text();
  $font    = $pdf->corefont('Times-Roman');

  $text->translate(30,700);  #primero se mueve en la misma fila,distinta columna. Segundo mas cerca del 0 mas abajo en la hoja
  $font = $pdf->corefont('Times-Bold');
  $text->font($font,12);
  $text->text("2. Consumo de energía eléctrica mensual");
  $font = $pdf->corefont('Times-Roman');
  $text->font($font,12);
  $text->translate(50,660);  
  $text->text("La siguiente tabla  presenta un resumén mensual de la generación eléctrica mensual produ-");
  $text->translate(50,640); 
  $text->text("cida por la instalación fotovoltaica. Ambos valores se encuentran expresados en kWh:");

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
"         G.E [kWh]"],
["Enero",
"         $generacion[0]"],
["Febrero",
"         $generacion[1]"],
["Marzo",
"         $generacion[2]"],
["Abril",
"         $generacion[3]"],
["Mayo",
"         $generacion[4]"],
["Junio",
"         $generacion[5]"],
["Julio",
"         $generacion[6]"],
["Agosto",
"         $generacion[7]"],
["Septiembre",
"         $generacion[8]"],
["Octubre",
"         $generacion[9]"],
["Noviembre",
"         $generacion[10]"],
["Diciembre",
"         $generacion[11]"],
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
    next_y  => 560,
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
  $text->font($font,12);
  $text->translate(50,250);  
  $text->text("G.E: Generación eléctrica fotovoltaica mensual, expresado en kWh.");
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


############### 3 hoja con gráfico
  $page    = $pdf->openpage('3');
  $text    = $page->text();

######creación del grafico
  my $data = GD::Graph::Data->new([
      ["E","F","M","A","M","J","J", "A", "S", "O", "N","D"],
      [ $consumo[0], $consumo[1]  , $consumo[2],$consumo[3], $consumo[4],  $consumo[5], $consumo[6], $consumo[7],     
       $consumo[8],$consumo[9],$consumo[10],$consumo[11]],
      [ $generacion[0]  ,  $generacion[1],$generacion[2],$generacion[3],$generacion[4],$generacion[5],$generacion[6],
          $generacion[7], $generacion[8],     $generacion[9], $generacion[10],$generacion[11]],

  ]) or die GD::Graph::Data->error;
   
   
  my $graph = GD::Graph::mixed->new;
     
  $graph->set( types => ['bars','lines' ] );

  $graph->set( line_types => [1], dclrs => [ qw(red blue ) ],
  line_width=> 2  );

  $graph->set( 
      x_label         => 'Meses',
      y_label         => 'KWh',
      interlaced    => 0,
      #title           => 'Producción vs Consumo',
   
      #y_max_value     => 12,
      #y_tick_number   => 12,
      #y_label_skip    => 3,
   
      #x_labels_vertical => 1,
   
      bar_spacing     => 2,
      shadow_depth    => 1,
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
  $text->translate(180,700); 
  $text->text("Gráfico Generación Eléctrica Fotovoltaica");
     $font = $pdf->corefont('Times-Roman');
    $text->font($font,12);
  $text->translate(50,300); 
  $text->text("La línea indica generación eléctrica fotovoltaica.");
 
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


  my $nombreReporte= int(rand(10000000000));
  $nombreReporte.= ".pdf";
 # print $nombreReporte;

  $pdf->saveas("$REPORTE"."$nombreReporte");
  $pdf->end;

  return $nombreReporte;



}
sub calculaTipoUsuario{
  my ($tipoUsuario,@consumo)= @_;
  my $consAnual=0;
  map { $consAnual += $_ } @consumo;

    switch ($tipoUsuario) {
          case 1    { return 2,3433;} #T1-R1
                      
          case 2  { switch ($consAnual) { #T1-R2

                      case [0..6000] {return 2.2926} 
                      case [6001..8400] {return 2.4121}
                      case [8401..16800] {return 2.3982;}
                      else {return 2.6011}
                    }
          }
          case 3 { return 2.7570 } #T1-G1
          case 4 {  switch ($consAnual) { #T1-G2
                      case [0..24000] {return 2.4564 }
                      else {return 2.5298}
                    } 
          }
          case 5  { return 2.8060 } #T1-AP
          case 6  { return 1.2013 } #T2-Ba
          case 7  { return 2.2492 } #T3-Ba 
          case 8  { return 3.0553} #T3-Bm
          case 9  { return 3.2493}#T3-Me 
          case 10 { return 3.4636} #  T3-Mm
          case 11  { return 2.5537} #T3-Al
          case 11  { return 1.9987} #T4-Ba

          case 12 {return 2.0524} #T5-Ba
          case 13 {return 2.5359} #T5-Bm
          case 14 {return 2.3140} #T6-Me
          case 15 {return 2.799}  #T6-Mm
          case 16 {return 3.1546} # T7-Ba
          case 17 {return 2.926}  #T8
          case 18 {return 3.3432} #T8-m
          else {return 2.019} #no identificado
    }
          
}
sub calculaNombreUsuario{
     my $tipoUsuario= $_[0];

    
     switch ($tipoUsuario) {
          case "1"    { return "T1-R1";}
                      
          case "2"  {   return "T1-R2" }
          
          case "3" { return "T1-G1" }
          case "4" {  return "T1-G2"  } 
          
          case "5"  { return "T1-AP" }
          case "6"  { return "T2-Ba" }
          case "7"  { return "T3-Ba"}
          case "8"  { return  "T3-Bm"}
          case "9" { return "T3-Me"}
          case "10"  { return "T3-Mm"} #tarifa 3 alta tension - gran demanda
          case "11"  { return "T3-Al"} #tarifa 4
          case "12" {return "T4-Ba"}
          case "13" {return "T5-Ba"}
          case "14" {return "T5-Bm"}#tarifa 6
          case "15" {return "T6-Me"}
          case "16" {return "T6-Mm"}
          case "17" {return "T7-Ba"} #tarifa 8
          case "18" {return "T8"}
          case "19" {return "T8-m"}
          else {return "no identificado"}

      }
  }
1;