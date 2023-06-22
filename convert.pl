#! /usr/bin/perl -w
use strict;
use Data::Dumper;
use Math::BigFloat; 
use Excel::Writer::XLSX;

my $datalink = 'dti_1pr_lli_tm05fflvt_16x16_t1bw6x_m_hc.ds';

my %db = read_data($datalink);

addDataToXSXL(\%db);






sub addDataToXSXL {
  my $db = (@_);
  my $Excelbook = Excel::Writer::XLSX ->new('tsmc05ff_1prhc (1).xlsx');
  die "problems creating new Excel file : $!"unless defined $Excelbook;
  my $Excelsheet = $Excelbook -> add_worksheet();
  my $format = $Excelbook -> add_format(bg_color =>'#00FFFF',);
  my $format1 = $Excelbook -> add_format(bg_color => '#CCFFCC',);
  $Excelsheet -> write("A1","typ",$format);
  $Excelsheet -> write("A2",["type",
                            "word",
                            "io",
                            "mux",
                            "seg",
                            "drawing dimension area(um^2)",
                            "access_time(ns)",
                            "cycle_time(ns)",
                            "adr_setup(ns)",
                            "adr_hold(ns)",
                            "data_setup(ns)",
                            "data_hold(ns)",
                            "data_hold(ns)",
                            "writec(uA/MHz)",
                            "leakage(uA)",
                            "leakage_slp(uA)",
                            "leakage_dslp(uA)",
                            "leakage_sd(uA)",
                            "PeripheralVT",
                            "totalKbits",
                            "P",
                            "V",
                            "T",
                            "options",
                            ],$format1);
  $Excelsheet ->write("A3",[$db->{type},
                            $db->{word},
                            $db->{io},
                            $db->{mux},
                            "",
                            $db->{draw},
                            $db->{T_RWM}->{'011'}->{Taa}->[0],
                            $db->{T_RWM}->{'011'}->{Tcc}->[0],
                            $db->{SETUP}->{typ}->[0] < $db->{SETUP}->{typ}[5] ? $db->{SETUP}->{typ}[5] : $db->{SETUP}->{typ}->[0],
                            $db->{HOLD}->{typ}->[0] < $db->{HOLD}->{typ}[5] ? $db->{HOLD}->{typ}[5] : $db->{HOLD}->{typ}->[0],
                            $db->{SETUP}->{typ}[3] < $db->{SETUP}->{typ}[8] ? $db->{SETUP}->{typ}[8] : $db->{SETUP}->{typ}[3],
                            $db->{HOLD}->{typ}[3] < $db->{HOLD}->{typ}[8] ? $db->{HOLD}->{typ}[8] : $db->{HOLD}->{typ}[3],
                            $db->{DALP}->{RD_Pwr}->{100}->[0],
                            $db->{DALP}->{WRT_Pwr}->{100}->[0],
                            $db->{DALP}->{LeakPwr}->[0],
                            $db->{LLP}->{LS}->[0],
                            $db->{LLP}->{DSLS}->[0],
                            $db->{LLP}->{DS}->[0],
                            "",
                            $db->{word} * $db->{io},
                            "",
                            $db->{TempVol}->{Vol}->[0],
                            $db->{TempVol}->{Temp}->[0], 
                            "",]
                      );
  $Excelbook->close;
}




###########################################################################
sub read_data {
  my ($data) = @_;
  my %db;
  my %T_RMW;
  my %low;
  my $num;
  my $start = 0;
  my $piece1 = 0;
  my $piece2 = 0;
  my $added = 0;
  my @name;
  my $table;
  my $hashname = "";
  my $per = 0;
  my @more;

  my @tables = ("T_RWM = ","Dynamic and Leakage Power","Low Leakage Power","Low Leakage Switching Power","Minimum Low Leakage","SETUP","HOLD","Pin Capacitance", "Temp");
  my @tablename = ("T_RWM","DALP","LLP","LLSP","MLL","SETUP","HOLD","PC","TempVol");

  open(DATA,'<'.$data) or die "cannot open $data";

  while( my $string = <DATA>) {
    next if($string =~ "\^\n" || ($string !~ /\w/ && $string =~ /\|/)); 
    chomp $string;

    if($string =~ /Bitcell/){
      my @words = split("Bitcell", $string);
      $db{type} = lc($words[0]);
    }

    #######################################
    if($string =~ s/^Logical Depth\: //){
      my @words = split(/\s/, $string);
      $db{word} = lc($words[0]);
    }

    #######################################
    if($string =~ s/^.*Logical Width\: //){
    #   print $string;
      my @words = split(/\s/, $string);
      $db{io} = lc($words[0]);
    }

    #########################################
    if($string =~ s/^.*Mux Option: //){
      $db{mux} = $string;
    }

    ########################################
    if($string =~ s/^.*Macro Size: //){
      my @words = split(/[\s"um""x"]+/, $string);
      my $draw = sprintf("%.4f", $words[0]) *  sprintf("%.4f", $words[1]);
      $db{draw} = sprintf("%.2f", $draw);
    }


    for my $tab (0 .. $#tables){
      if($string =~ $tables[$tab] && $start == 0) {
        $start = 1;
        $hashname = $tablename[$tab];
        if($tab == 0){
          my @nums = split('"',$string);
          $num = $nums[1];
        }
        next;
      }
    }

    if($start == 1 && $string =~ /======/ && $piece2 == 0){
      $piece1 = 1;
      next;
    }

    if($start == 1 && $string =~ /------/ && $piece1 == 1){
      $piece1 = 0;
      $piece2 = 1;
      next;
    }

    if($start == 1 && $piece2 == 1 && ($string =~ /\*\*\*\*\*\*\*\*\*\*\*\*\*\*\*\*\*\*\*/ || $string =~ /=========/)){
      $piece2 = 0;
      $start = 0;
      $hashname = "";
      next;
    }

    if($hashname eq "TempVol" && $piece2 == 0){
      $piece1 = 1;
    }

# print $hashname;

#########################################################################
    if($piece1){
      if($hashname eq "T_RWM"){
        if($added == 0){
          @name = split(' ',$string);
          $added = 1;
        }
      }
      elsif($hashname eq "DALP"){
        $string =~ s/\|//g;
        if($added == 0){
          @name = split(' ',$string);
          $added = 1;
        }
        if($string =~ /\*ActivityF/){
          $string =~ s/\%//g;
          @more = split(' ',$string);
          $per = 1;
        }
      }
      elsif($hashname eq "LLSP"){
        if($added == 0){
          @name = split("  +",$string);
          $added = 1;
        }
        if($string =~ /LKRB/){
          $string =~ s/\"//g;
          @more = split(' ',$string);
        }
      }
      elsif($hashname eq "MLL" || $hashname eq "LLP"){
        if($added == 0){
          @name = split("  +",$string);
          $added = 1;
        }
      }
      elsif($hashname eq "SETUP" || $hashname eq "HOLD" || $hashname eq "PC" ){
        if($added == 0){
          @name = split(" ",$string);
          $added = 1;
        }
      }
      elsif($hashname eq "TempVol"){
        $string =~ s/\.//g;
        if($added == 0){
          @name = split(" ",$string);
          $added = 1;
        }
      }
    }
#########################################################################
    if($piece2){
      $added = 0;
      if($hashname eq "T_RWM"){
        my @words = split(' ',$string);
        for my $i (1 .. $#name) {
          push(@{$db{$hashname}{$num}{$name[$i]}},$words[$i]) 
        }
      }
      elsif($hashname eq "DALP"){
        $string =~ s/[\|"uW""uA"]+//g;
        my @words = split(' ',$string);
        for my $i (0 .. $#name) {
          if($more[$i + 1] eq '0'){
            push(@{$db{$hashname}{$name[$i]}},$words[$i + 2]) 
          }
          else{
            push(@{$db{$hashname}{$name[$i]}{$more[$i + 1]}},$words[$i + 2]) 
          }
        }
      }
      elsif($hashname eq "LLSP"){
        my @words = split(' ',$string);
        for my $i (1 .. $#name) {
          push(@{$db{$hashname}{$name[$i]}{$more[$i - 1]}},$words[$i]);
        }
      }
      elsif($hashname eq "MLL" || $hashname eq "LLP"){
        my @words = split(' ',$string);
        for my $i (1 .. $#name) {
          push(@{$db{$hashname}{$name[$i]}},$words[$i]);
        }
      }
      elsif($hashname eq "SETUP" || $hashname eq "HOLD" || $hashname eq "PC" ){
        $string =~ s/\[.*\]//g;
        my @words = split(' ',$string);
        for my $i (1 .. $#name - 1) {
          push(@{$db{$hashname}{$name[$i + 1]}},$words[$i]);
        }
      }
      elsif($hashname eq "TempVol"){
        my @words = split("  +",$string);
        for my $i (2 .. $#name) {
          push(@{$db{$hashname}{$name[$i]}},$words[$i + 1]);
        }
      }
    }
  }
  close(DATA);
  open(DATA, '>dumper.txt');
  print DATA Dumper(%db);
  close(DATA);
  return %db;
}
