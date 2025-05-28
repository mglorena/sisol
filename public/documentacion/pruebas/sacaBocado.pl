#! /usr /bin /perl 

use Data::Dumper;


my $lat=-24.78;
my $long=-65.41;
my $map= "perro.nc";

`cdo remapnn,lon=$long/lat=$lat mensual.nc $map`;

my $salida=`cdo outputtab,value perro.nc`;

my @radiacionMensual = split(/\n /, $salida);

print Dumper \@radiacionMensual	