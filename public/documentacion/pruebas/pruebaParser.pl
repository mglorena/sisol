use Math::Trig;
use Data::Dumper;
use CGI;
use Data::Dumper;
use LWP::UserAgent;
use Parse::RecDescent;
use Regexp::Grammars; 
use JSON::XS qw(encode_json decode_json);
use File::Slurp qw(read_file write_file);



my $sentence= '{"X_MIN":-64.34238456829947,"X_MAX":-64.30045530659946,"Y_MIN":-25.852303086499884,"Y_MAX":-25.810305631999885,"Enero":82.53895,"Febrero":166.66101,"Marzo":154.20004,"Abril":184.42818,"Mayo":176.11292,"Junio":170.65209,"Julio":14501,"Agosto":190.77834,"Septiembre":128.93161,"Octubre":104.35889,"Noviembre":122.69742,"Diciembre":158.90013,"mesEnero":158.90013,"mesAnual":158.90013}}]';

print Dumper parser($sentence);

sub parser{
	my ($sentence)= @_;

	my @parser=(parserDia($sentence),parserMes($sentence));

	return @parser;

}

sub parserDia{
	my ($sentence)= @_;

	$parser = qr{
        <Block>

        <rule: Block> 	<[cadena]>+


        <rule: cadena>  \"<mes>\"\: <numeros>\,|\"mesEnero\"\:

        <rule: mes>      Enero|Febrero|Marzo|Abril|Mayo|Junio|Julio|Agosto|Septiembre|Octubre|Noviembre|Diciembre|Anual

        <rule: numeros>      [.0-9]+   


    }xms ;

		$sentence =~ s/$parser//;
		my %radiacion;
		foreach my $val (values %/{Block}->{cadena}) { 
			$radiacion{$val->{'mes'}} .=$val->{'numeros'};
		}
		
		my $jsonDia= encode_json \%radiacion;

		#write_file('radiacionMensual.json', { binmode => ':raw' }, $json);
		return $jsonDia;
	}

sub parserMes{
	my ($sentence)= @_;

	$parser = qr{
        <Block>

        <rule: Block> 	<[cadena]>+


        <rule: cadena>  \"mes<mes>\"\: <numeros>\,|\"mes<mes>\"\: <numeros>\}

        <rule: mes>      Enero|Febrero|Marzo|Abril|Mayo|Junio|Julio|Agosto|Septiembre|Octubre|Noviembre|Diciembre

        <rule: numeros>      [.0-9]+   


    }xms ;

		$sentence =~ s/$parser//;
		my %radiacion;
		foreach my $val (values %/{Block}->{cadena}) { 
			$radiacion{$val->{'mes'}} .=$val->{'numeros'};
		}
		
		my $jsonMes= encode_json \%radiacion;

		#write_file('radiacionMensual.json', { binmode => ':raw' }, $json);
		return $jsonMes;
	}

1;