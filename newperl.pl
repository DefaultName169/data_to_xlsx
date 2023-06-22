#! /usr/bin/perl -w

# Purpose :

# Creation Date : 27-04-2023

# Last Modified : 

# Created By : 

###############################################################
### Define lib ###
#  use strict;
use Data::Dumper;
use Excel::Writer::XLSX;
use File::Basename;


if (not defined $ARGV[0]) {
  print <<END;
    perl $0 <dir>
      dir:folders contain <.ds> file
END
}

my $dir = $ARGV[0];
$dir = dirname($0);
my @files = <"$dir/test/dti*/*.ds">;
# my @files = <"$dir/newdata2/dti_2prp_lli_tm12ffcll_1024x16_t4bw6x_hc/dti_2prp_lli_tm12ffcll_1024x16_t4bw6x_hc.ds">;
# my @files = <"$dir/newdata/dti_dp_lli_tm12ffcll_8192x8_t32bw6x_hc/dti_dp_lli_tm12ffcll_8192x8_t32bw6x_hc.ds">;
# my @files = <"$dir/data/dti_1pr_lli_tm05fflvt_32x64_t1bw6x_m_hc/dti_1pr_lli_tm05fflvt_32x64_t1bw6x_m_hc.ds">;



my @param = (
  ['IP'                                           ,'{ip}'],
  ["Instance"                                     ,'{word} . \'x\' . {io} . \'m\' . {mux}'],
  ["Bit-Cell"                                     ,'{type}'],
  ["Periphrey\nRead Assist\n(75mV)"               ,'{vt}'],
  ["Read\nAssist\n(75mV)"                          ,'yes'],
  ["Write\nAssist\n(100mV)"                        ,'yes'],
  ['[$title]', '$this:{param}->{p} . \'/\' . $this:{param}->{vol} . \'V/\' . $this:{param}->{temp} . \'C\'',
              [  
                ["Speed\n(MHz)"                   , '$this:{param}->{hz}'],		
                ["Access\ntime\n(ps)"              , '( {$this:{param}->{process}}->{vals}:{param}->{load} == 0 ) && ( {$this:{param}->{process}}->{vals}:{param}->{process} eq $this:{param}->{pin})'
                                                  , '$this:{param}->{taa}'],	
                ["Cycle\ntime\n(ps)"               , '( {$this:{param}->{process}}->{vals}:{param}->{load} == 0 ) && ( {$this:{param}->{process}}->{vals}:{param}->{process} eq $this:{param}->{pin})'
                                                  , '$this:{param}->{tcc}']
              ],
    '{max}->{vals}'
  ],
  ['[$title]', '$this:{param}->{p} . \'/\' . $this:{param}->{voltage} . \'V/\' . $this:{param}->{temp} . \'C\'',
              [
                ["Active\nCurrent\n(mA/MHz)"       , '( {dalp}->{vals}:{param}->{process} eq $this:{param}->{process} ) && ( {dalp}->{vals}:{param}->{unit} eq \'ma/ghz\')',
                                                  , '$this:{param}->{wrt_pwr100%}'],
                ["Stand-by\nCurrent\n(mA/GHz)"     , '( {dalp}->{vals}:{param}->{process} eq $this:{param}->{process} ) && ( {dalp}->{vals}:{param}->{unit} eq \'ma/ghz\')',
                                                  , '$this:{param}->{leakpwr0%}'],
                ['[$title]'                       , "Power-down Current\n(uW)",  
                                                  [
                                                    ["DS"                     ,'( {llp}->{vals}:{param}->{process} eq $this:{param}->{process} )'
                                                                              , '$this:{param}->{ds}'],
                                                    ["LS"                     ,'( {llp}->{vals}:{param}->{process} eq $this:{param}->{process} )'
                                                                              , '$this:{param}->{ls}'],
                                                    ["DSLS"                   ,'( {llp}->{vals}:{param}->{process} eq $this:{param}->{process} )'
                                                                              , '$this:{param}->{dsls}']
                                                  ],
                                                  '{tempvol}->{vals}:{param}->{process} eq \'ffgnp125c\''
                                                  ]
              ],
    '{tempvol}->{vals}:{param}->{process} eq \'ffgnp125c\''
  ],
  ["Area (um2)\nPre-Shrink",                      ,'{draw}']
);

my $param_depp = ();

my ($output, $location_value_output) = &read_data( \@files , \@param); 
# print Dumper $output;
# print Dumper $location_value_output;
# print Dumper %excel;

my $Excelbook = Excel::Writer::XLSX -> new('test.xlsx');
my $sheetname;
my $Excelsheet = $Excelbook -> add_worksheet($sheetname);
my $titleformat = $Excelbook -> add_format(
                                              'bg_color'  => 'yellow',
                                              'text_wrap' => 0
                                            );
my $blueformat = $Excelbook -> add_format(  'bg_color'    =>'#000066',
                                            'text_wrap'   => 1,
                                            'border'      => 2,
                                            'border_color'=> 'white',
                                            'valign'      => 'vcenter',
                                            'align'       => 'center',
                                            'color'       => 'white',
                                            'bold'        => 1,
                                            'font'        => 'Arial',
                                          );
my $string_evalformat = $Excelbook -> add_format(   'bg_color'    => '#DAEEF3',
                                              'text_wrap'   => 1,
                                              'border'      => 2,
                                              'border_color'=> 'white',
                                              'valign'      => 'vcenter',
                                              'align'       => 'center',
                                              'color'       => 'black',
                                              'font'        => 'Arial',
                                            );
my $int_evalformat = $Excelbook -> add_format(   'bg_color'    => '#DAEEF3',
                                              'text_wrap'   => 1,
                                              'border'      => 2,
                                              'border_color'=> 'white',
                                              'valign'      => 'vcenter',
                                              'align'       => 'left',
                                              'color'       => 'black',
                                              'font'        => 'Arial',
                                            );
my $note_evalformat = $Excelbook -> add_format(   'bg_color'    => '#DAEEF3',
                                              'text_wrap'   => 1,
                                              'border'      => 2,
                                              'border_color'=> 'white',
                                              'valign'      => 'vcenter',
                                              'align'       => 'left',
                                              'color'       => 'black',
                                              'font'        => 'Arial',
                                              'bold'        =>  1
                                            );
my $greenformat = $Excelbook -> add_format(  'bg_color'   => '#00B050',
                                              'text_wrap'   => 1,
                                              'border'      => 2,
                                              'border_color'=> 'white',
                                              'valign'      => 'vcenter',
                                              'align'       => 'center',
                                              'color'       => 'white',
                                              'bold'        => 1,
                                              'font'        => 'Arial',
                                            );

my @ABC = (A..Z);
@more = ();
for my $i(@ABC){
  push @more , 'A'. $i;
}
push @ABC , @more;

# for my $i(0 .. $#{$output}){
  my @sorted = sort { length $b <=> length $a } @{$location_value_output};
  my @arr_deep = split /\[/ , $sorted[0];
  my $deep = (@arr_deep + 1) / 3;
  my $column = 0;
  printExcel(\$Excelsheet, $output, $location_value_output , '', $deep , 1 , \$column);
  my @eval = @{ eval('$output->' . $location_value_output->[0] ) };
  my $newrow = @eval + $deep;
  my $note = 
"Note:   DS:   \n
        LS:    \n
        DSLS:   \n
";
  $Excelsheet->merge_range('B'.$newrow.':L'.$newrow, $note, $note_evalformat);
  $Excelsheet->set_row($newrow - 1,100);
# }

# AddDataToXSXL(\$Excelbook,\%excel);
  # ParamToXLSX(\$Excelbook,@output);
# AddDataToXSXL(\$Excelbook,\%excel ,"word","mux","io");
# AddDataToXSXL(\$Excelbook,\%excel ,"word","io","mux");
# AddDataToXSXL(\$Excelbook,\%excel ,"mux","word","io");
# AddDataToXSXL(\$Excelbook,\%excel ,"io","word","mux");
$Excelbook->close;  


sub read_data {
  my ($files, $paraminput) = @_;
  my %data = ();
  my @output = ();    
  my @location_value_output = ();
  
  for my $i (0 .. $#files) {  
    my $file = $files[$i];
    my $name =  $file;
    $name=~ s/(^.+\/)//;
    print "Info: Read file $file\n";
    open DS, "$file" or die "$file $!";

    my $pline = "";
    my $change = 0;
    my $special_unit = ();
    while (<DS>) {
      $_ = lc($_);
      chomp ;
      if( /^setup\((\w+)\)/ or $_ =~ /^hold\((\w+)\)/ or $_ =~ /^pin\s+capacitance\((\w+)\)/ ){
        $special_unit = $1;
        $change = 1;
      }
      preprocess(\$_);
      read_permanentdb(\$_, \%data, \$name);

      my $paramstr = '';
      my $unitstr = '';
      my $morestr = '';
      my $title = '';
      if (/process\s+description\s+temp.\s+voltage/){
        $title = 'tempvol';
        $_ =~ s/process\s+description\s+temp.\s+voltage/process    description        p     temp  voltage/;
        $paramstr = $_;
      }

      if (/^=+$/ or $title ne '') {
        if($title eq ''){
          $title = $pline;
        }
        
        next if( $title =~ /pin\sdescription/);
        if($title eq ""){
          $title = 'width';
        }

        my $flagv = 0;
        my @units = ();
        my @space;
        # @{$data{$name}{$title}{vals}} = ();
        
        while (<DS>) {
          $_ = lc($_);
          last if /^\*+$/ or /^\=+$/;
          if($title =~ /maximum/){
            s/\// /g;
            $data{$name}{max}{param} = ['process', 'p','temp','vol', 'hz'];
            my @lines = split /\s+/ , $_;
            $lines[-6] =~ s/(t_rwm)(?:.\S+)?(\(\d+\))/$1$2/ ;
            $lines[-2] =~ s/v\://;
            $lines[-3] =~ s/c//;
            $lines[-1] =~ s/mhz//;
            my $process = $lines[-6];
            my $p = $lines[-4];
            my $temp = $lines[-3];
            my $vol = $lines[-2];
            my $hz = $lines[-1];
            push @{$data{$name}{max}{vals}}, [ $process, $p, $temp, $vol, $hz ];
            next;
          }

          preprocess(\$_);
          chomp;          
          
          if($paramstr eq ''){
            $paramstr = $_;
          }

          if($morestr eq '' and /more/){
            $morestr = $_;
          }

          if (/^---/) {          
            if($unitstr eq '' and $pline =~ /\(\w+\)/){
              $unitstr = $pline;
            }
            my $newstr = $_;
            while($newstr =~ /(^.*-)([\s+\+]+)/) {
              my $start = (length $1) + 1;
              my $length = (length $newstr) - $start;
              push @space , "$start,$length";
              $newstr = $1;
            }
            my $length = length $newstr;
            push @space , "0,$length";
            @space = reverse(@space);
            $flagv = 1;
            next;
          }
          ##################################################################################
          if ($flagv == 1 and /^\S+/) {
            my @val;
            for my $i (@space){
              my @sub = split /\,/ , $i;
              my $a = substr($_, $sub[0],$sub[1]);
              $a =~ s/\s//g;
              $a =~ s/\[.*\]//g;
              $a =~ s/(^(?:-)?\d+(?:\.\d+)?)(.*)/$1/;
              push @val, $a;
            }
            push @{$data{$name}{$title}{vals}}, [@val];
          }
          $pline = $_;
        }        
        next if($title =~ /max/);
        if (not defined $data{$name}{$title}{param}[0]) {
          for my $i (@space){
            my $more = '';
            if($unitstr ne ''){
              my @sub = split /\,/ , $i;
              my $a = substr($unitstr, $sub[0],$sub[1]);
              $a =~ s/\s//g;
              if($a =~ /\((\w+)\)/){
                $a = $1;
              } ;
              push @{$data{$name}{$title}{unit}}, $a;
            }
            ############################################################################
            if($morestr ne ''){
              my @sub = split /\,/ , $i;
              $more = substr($morestr, $sub[0],$sub[1]);
              $more =~ s/\s//g;
            }
            my @sub = split /\,/ , $i;
            my $a = substr($paramstr, $sub[0],$sub[1]);
            $a =~ s/\s//g;
            $a = $a . $more if ($more !~ /more/);
            push @{$data{$name}{$title}{param}}, $a;
          }
        }
        if($change == 1){
          if(!@pin){
            push @pin, @{$data{$name}{$title}{param}};
            shift @pin;
          }
          ColumnToRow(\$data{$name},\$title,\$special_unit);          
          $change = 0;
          $special_unit = ();
        }
      }
      $pline = $_;
    }
    close(DS);

    ######################## add pin to max ##############################
    my %numbermax = ();
    @numbermax{ @{$data{$name}{max}{param}} } = (keys @{$data{$name}{max}{param}});    
    my %numbertempvol = ();
    @numbertempvol{ @{$data{$name}{tempvol}{param}} } = (keys @{$data{$name}{tempvol}{param}});  
    for my $i (0 .. $#{$data{$name}{max}{vals}}){
      for my $j(0 .. $#{$data{$name}{tempvol}{vals}}){
        if(( $data{$name}{max}{vals}[$i][$numbermax{p}] eq $data{$name}{tempvol}{vals}[$j][$numbertempvol{p}] ) and
           ( $data{$name}{max}{vals}[$i][$numbermax{vol}] eq $data{$name}{tempvol}{vals}[$j][$numbertempvol{voltage}] ) and
           ( $data{$name}{max}{vals}[$i][$numbermax{temp}] eq $data{$name}{tempvol}{vals}[$j][$numbertempvol{temp}] ))
        {
          unless( grep( /pin/, @{$data{$name}{max}{param}} )){
            push @{$data{$name}{max}{param}} , 'pin';
          }
          push @{$data{$name}{max}{vals}[$i]} , $data{$name}{tempvol}{vals}[$j][$numbertempvol{process}];
          last;
        }
      }
    }
    #####################################################################
    
    my @params = @{$paraminput};
    my @paramclean = ();

    for my $i (0 .. $#params) {
      my $param = $params[$i][0];
      my $key   = $params[$i][1];
      my $title = scalar @{$params[$i]} > 2 ? $params[$i][-1] : '';

      if($param ne '[$title]'){
        if($key =~ /\{/){
          my $key = $key;
          my $string = ParamToEval($key, '' , \$name, \%data);
          $string =~ s/\s+//g;
          $paramclean[$i][0] = $params[$i][0];
          $paramclean[$i][1] = $string;
        }
        else{
          $paramclean[$i][0] = $params[$i][0];
          $paramclean[$i][1] = $params[$i][1];
        }
      }
      
      else{
        my @returnparam = iftitle(\@{$params[$i]}, \$name, \%data);
        @{$paramclean[$i]} = @returnparam;
      }
    }

    if(!@output){
      push @output, [@paramclean];
      if(!@location_value_output){
        $location_value_output[0] = ();
        findValueLocation(\@{$location_value_output[0]}, \@paramclean , '');
      }
    }
    else{
      my $true = 1;
      for my $i(0 .. $#output){
        $true = 1;
        my @param = @{$output[$i]};
        for my $i(0 .. $#param){
          if(ref($param[$i][0]) eq 'ARRAY'){
            for my $j(0 .. $#{$param[$i]}){
              if($param[$i][$j][0] ne $paramclean[$i][$j][0]){
                $true = 0;
                last;
              }
            }
            last if($true == 0);
          }
          last if($true == 0);
        }          
        if(!$true){
          next if($i != $#output);
          push @output, [@paramclean];
          findValueLocation(\@{$location_value_output[$i]}, \@paramclean , '');
        }
        else {
          if(!defined $location_value_output[$i]){
            findValueLocation(\@{$location_value_output[$i]}, \@paramclean , '');
          }
          for my $j (@{$location_value_output[$i]}){
            my $eval = "push \@\{\$output\[$i\]$j\} , \$paramclean$j\[1\]";
            eval($eval);
          }
        }
      }
    }
  } 
  return (@output , @location_value_output);
}

sub pushoutput {
  my ($param , $paramclean , $str) = $_;
  my @param = @{$param};
  for my $i(0 .. $#param){
    my @param = $param[$i];
    my $value = ();
    $str .= '['.$i.']';

    while(1){
      if(ref($param[0]) eq 'ARRAY'){
        @param = @{$param[0]};
      }
      elsif(ref($param[1]) eq 'ARRAY'){
        @param = @{$param[1]};
      }
      else{
        $str .= '[1]';
        $value = $param[1];
        last;
      }
    }
  }
}

sub iftitle {
  my ( $paraminput , $name, $data ) = @_;
  # my @paraminput = ();

  # print Dumper $paraminput;
  my @params = ();
  for my $i(0 .. $#{$paraminput}){
    $params[$i] = $paraminput->[$i];
  }

  my @paramclean = ();

  my $param = $params[0];
  my $key   = $params[1];
  my $title = $params[-1];
  my @thiss = ParamToEval($title, '' , $name, $data);

  for my $this (@thiss){
    my $newtitle = ParamToEval($key, $this, $name, $data);
    $newtitle = eval($newtitle);
    if(!defined $newtitle){
      $newtitle = $key;
    }
    my @values = @{$params[2]};
    my @options;
    for my $k(0 .. $#values){
      my $val = ();
      my $that = $this;
      if( $values[$k][0] eq '[$title]'){
        my @returnparam = iftitle(\@{$values[$k]} , $name, $data);
        push @options , [@returnparam];
      }
      else{
        for my $h (1 .. $#{$values[$k]}){
          if($h == $#{$values[$k]}){
            $val = ParamToEval($values[$k][$h], $that , $name, $data);
            $val =~ s/\'|\s+//g;
          }
          else{
            my @array = ParamToEval($values[$k][$h], $that , $name, $data);
            $that = $array[0];
          }
        }
        push @options , [$values[$k][0], $val];
      }
    }
    push @paramclean, [$newtitle, [@options]];
  }
  return @paramclean;
}

sub ParamToEval {
  my ($title, $this, $name , $data) = @_;
  my $newtitle = '';
  my @eval = ();
  # print "$title\n\n\n";

  while($title =~ /\$this\:(\{\w+\})->\{(\w+%?)\}/){
    my $key1 = $1;
    my $key2 = $2;
    my $str = $this;
    my $true;
    $str =~ s/\{vals\}.*/$key1/;             
    my @parames = @{eval($str)};               #$data{$name}->{tempvol}->{param}-> {}
    
    for my $j(0 .. $#parames){
      if($parames[$j] eq $key2){
        $true = $j;
        last;
      }
    }    
    
    my $string = $this . '->[' .$true. ']';

    my $eval = '\'' . eval($string) . '\'';
    $title =~ s/\$this\:\{\w+\}->\{\w+%?\}/$eval/;
  }

  my @keys = split /\s+/, $title;

  for my $k(@keys){ 
    my $string = $k . ' ' ;
    if($k =~ /(.*):(.*)/) {
      my $key1 = $1;
      my $key2 = $2;

      if($key2 =~ /(.*)->\{(.*)\}/){
        my $key21 = $1;                               #param
        my $key22 = $2;                               #p      
        my $keys = '$data->{$$name}->' . $key1;        #$data{$name}->{tempvol}->{vals}
        my $str2 = $keys;    
        my $true = ();
        $str2 =~ s/\{vals\}.*/$key21/g;
        my @parames = @{eval($str2)};               #$data{$name}->{tempvol}->{param}-> {}
        
        for my $j(0 .. $#parames){
          if($parames[$j] eq $key22){

            $true = $j;
            last;
          }
        }
        my @evals = @{eval($keys)};
        if(defined $true){
          $string = '$data->{$$name}->' . $key1 . '->[0:'. $#evals .']->' . '[' . $true . ']'; #$data{$name}->{tempvol}->{vals}->[$i]->[]
        }
      }
    }      
    elsif($k =~ /(.*)->\{(.*)\}/){
      my $str = '$data->{$$name}->' . $title;

      my @there = @{eval($str)};

      if(ref($there[0]) ne 'ARRAY'){
        $str =~ s/\[(\d+)\]/[$1:$1]/;
        $string = $str;
      }
      else{
        $string = '$data->{$$name}->'.$title.'->[0:'. $#there .']';
      }
    }
    elsif($k =~ /^\{\w+\}/){
      $string = '$data->{$$name}->'.$k;
    }
    $newtitle .= $string;
  }   

  if($newtitle =~ /(\d+):(\d+)/){
    for my $i ($1 .. $2){
      my $str = $newtitle;
      $str =~ s/\d+:\d+/$i/g;

      if($str =~ /eq|ne|==|!=/){
        if(eval($str)){
          my @strs = split /\s+/, $str;
          for my $i (@strs){
            if($i =~ /^\$/){
              if($newtitle !~ /^\=/){
                $i =~ s/(.*)->.*/$1/;
              }
              $str = $i;
              push @eval , $str;
              last;
            }
          }
        }
      }
      else{
        push @eval , $str;
      }
    }
    $newtitle =~ s/(\d+):(\d+)/done/g;
  }
  elsif($newtitle !~ /->/){
    return $newtitle;
  }
  elsif($newtitle !~ /\[\d+\]/){

    my $string = eval($newtitle);

    return $string;
  }
  return @eval;
}

sub findValueLocation {
  my ($valuelocation, $array , $str) = @_;
  my @array = @{$array};

  for my $i (0 .. $#array){
    next if(ref($array[$i]) ne 'ARRAY');
    if(ref($array[$i][0]) eq 'ARRAY' || ref($array[$i][1]) eq 'ARRAY'){      # my $temp = $str;
      $str .= "\[$i\]";
      my @arrays = ();
      for my $j(0 .. $#{$array[$i]}){
        @arrays[$j] =  $array[$i][$j];
      }
      findValueLocation($valuelocation, \@arrays, $str);
    }
    else{
      $str .= "\[$i\]";
      push @{$valuelocation} , $str;
    }
    $str =~ s/\[\d+\]$//;
  } 
}

sub preprocess {
  s/^setup.*/setup/g;
  s/^hold.*/hold/g;
  s/^pin\scapacitance.*/pinc/g;
  s/^dynamic\sand.*/dalp/g;
  s/^low\sleakage\spower.*/llp/g;
  s/^low\sleakage\sswitching\spower/llsp/g;
  s/minimum\slow\sleakage.*/mll/g;    
  s/(^.*)(t_rwm)(?:.\S+)?(\(\d+\))(.*)/$2$3/;
  s/---------  ------------------------ ----- -----------------------------/---------  ----------------- ------ ----- -----------------------------/;
  s/\|/ /g;
  s/^.\s+rd_pwr/process            rd_pwr/g;
  s/\s+"!lkrb_n"/more          "!lkrb_n"/g;
  s/\@/ /g;
  s/^\*activityf\s+50\%/more        unit      50\%/g;
}

sub read_permanentdb {
  my ($string, $data, $name) = @_;
  $_ = $$string;
  if(s/bitcell.*//){
    $data->{$$name}->{type} = $_;
    if($$name =~ /dti_(\w+?)_/){
      $data->{$$name}->{ip} = $1 . '_' . $data->{$$name}->{type};
    }
  }

  #######################################
  elsif (/^logical.*:\s*(\d+).*\s+(\d+)/i) {
    $data->{$$name}->{word}     = $1;
    $data->{$$name}->{io}       = $2;
    $data->{$$name}->{totalbit} = $data->{$$name}->{word} * $data->{$$name}->{io};
    $data->{$$name}->{options}  = "'bw' 'test' 'll'";
    $data->{$$name}->{seg}      = "seg";
  }

  #########################################
  if(s/^.*mux\soption:\s//){
    $data->{$$name}->{mux} = $_;
  }

  ########################################
  if(s/^.*macro\ssize:\s//){
    my @words = split/[\s"um""x"]+/, $_;
    my $draw = sprintf("%.4f", $words[0]) *  sprintf("%.4f", $words[1]);
    $data->{$$name}->{draw} = sprintf("%.4f", $draw);
  }
  if(/threshold.*\((\S+)\)/) {
    $data->{$$name}->{vt} = $1;
  }
}

sub convertunit {
   my ($number,$last,$now) = @_; 

  my @cum = ('G','M','K','','m','u','n','p');
  my $up_last = '';
  my $down_last = '';
  my $up_now = '';
  my $down_now = '';

  if(my @num = $last =~ m/(\w{1}).[\/(\w{1}).+]?/g )  {
    $up_last = $num[0];
    $down_last = $num[1] if defined $num[1];
  }
  if(my @num = $now =~ m/(\w{1}).[\/(\w{1}).+]?/g )  {
    $up_now= $num[0];
    $down_now = $num[1] if defined $num[1];
  }

  my $num = sprintf '%.2f', $$number;
  my $match_up_last = -1;
  my $match_up_now = -1;
  my $match_down_last = -1;
  my $match_down_now = -1;

  for my $i (0 .. $#cum){
    if($up_last eq $cum[$i]){
      $match_up_last = $i;
    }
    if($up_now eq $cum[$i]){
      $match_up_now = $i;
    }
    if($down_last eq $cum[$i]){
      $match_down_last = $i;
    }
    if($down_now eq $cum[$i]){
      $match_down_now = $i;
    }
  }

  $$number = $num / 10**(3*($match_up_last - $match_up_now)) * 10**(3*($match_down_last - $match_down_now));
}

sub ColumnToRow {
  my ($hash, $name, $unit) = @_;
  my %newhash = ();

  push @{$newhash{$$name}{param}} , $$hash->{$$name}->{param}->[0];
  push @{$newhash{$$name}{unit}} , '';
  for my $i (0 .. $#{$$hash->{$$name}->{param}}) {
    if($i != 0){
      push @{$newhash{$$name}{vals}[$i-1]} , $$hash->{$$name}->{param}->[$i];
    }
    for my $j (0 ..  $#{$$hash->{$$name}->{vals}}) {
      if($i == 0){
        push @{$newhash{$$name}{param}} , $$hash->{$$name}->{vals}->[$j]->[$i];
        push @{$newhash{$$name}{unit}} , $$unit;
      }
      else{
        push @{$newhash{$$name}{vals}[$i-1]} , $$hash->{$$name}->{vals}->[$j]->[$i];
      }
    }
  }
  $$hash->{$$name} = $newhash{$$name};
}

sub sorttype {
  my ($data,@type) = @_;
  my @sorted = sort{  
                      $data->{$a}->{$type[0]} <=> $data->{$b}->{$type[0]} ||
                      $data->{$a}->{$type[1]} <=> $data->{$b}->{$type[1]} ||
                      $data->{$a}->{$type[2]} <=> $data->{$b}->{$type[2]}
                    } keys %$data;
  return @sorted;
}

sub ParamToXLSX {
  my ($Excelbook, $output, $location_value_output) = @_;

  my $sheetname;
  my $Excelsheet = $$Excelbook -> add_worksheet($sheetname);
  my $titleformat = $$Excelbook -> add_format(
                                                'bg_color'  => 'yellow',
                                                'text_wrap' => 0
                                              );
  my $blueformat = $$Excelbook -> add_format(  'bg_color'    =>'#000066',
                                              'text_wrap'   => 1,
                                              'border'      => 2,
                                              'border_color'=> 'white',
                                              'valign'      => 'vcenter',
                                              'align'       => 'center',
                                              'color'       => 'white',
                                              'bold'        => 1,
                                              'font'        => 'Arial',
                                            );
  my $string_evalformat = $$Excelbook -> add_format(   'bg_color'    => '#DAEEF3',
                                                'text_wrap'   => 1,
                                                'border'      => 2,
                                                'border_color'=> 'white',
                                                'valign'      => 'vcenter',
                                                'align'       => 'center',
                                                'color'       => 'black',
                                                'font'        => 'Arial',
                                              );
  my $int_evalformat = $$Excelbook -> add_format(   'bg_color'    => '#DAEEF3',
                                                'text_wrap'   => 1,
                                                'border'      => 2,
                                                'border_color'=> 'white',
                                                'valign'      => 'vcenter',
                                                'align'       => 'left',
                                                'color'       => 'black',
                                                'font'        => 'Arial',
                                              );
  my $greenformat = $$Excelbook -> add_format(  'bg_color'   => '#00B050',
                                                'text_wrap'   => 1,
                                                'border'      => 2,
                                                'border_color'=> 'white',
                                                'valign'      => 'vcenter',
                                                'align'       => 'center',
                                                'color'       => 'white',
                                                'bold'        => 1,
                                                'font'        => 'Arial',
                                              );

  
  # my $valueformat = $$Excelbook -> add_format(  
  #                                               'border'      => 1,
  #                                               'align'       => 'center'
  #                                             );
  # $Excelsheet->set_column(1, 3, 10);
  # $Excelsheet->set_column(4, scalar @params, 12);
  # my $row = 1;
  
  # my @ABC = (A..Z);
  # @more = ();
  # for my $i(@ABC){
  #   push @more , 'A'. $i;
  # }
  # push @ABC , @more;

  # for my $param(@output){
  #   @param = @{$param};
  #   my $column = 0;
  #   for my $i (0 .. $#param){
  #     my $column_size = 0;

  #     if(ref($param[$i][0]) ne 'ARRAY'){
  #       my @str = split /\n/ , $param[$i][0];
  #       for my $i (@str){
  #         if(length($i) > $column_size){
  #           $column_size = length($i);
  #         }
  #       }

  #       my $merge = $ABC[$column].$row.':'.$ABC[$column].($row + 1) ;

  #       $Excelsheet->merge_range($merge, $param[$i][0], $blueformat);
  #       my $thisrow = $row + 2;

  #       for my $j(1 .. $#{$param[$i]}){
  #         $length = length($param[$i][$j]);
  #         if( $length > $column_size){
  #           $column_size = length($param[$i][$j]);
  #         }
  #         if($param[$i][$j] =~ /^\d+(.\d+)?$/){
  #           $Excelsheet->write($ABC[$column].($thisrow), $param[$i][$j], $int_evalformat);
  #         }
  #         else{
  #           $Excelsheet->write($ABC[$column].($thisrow), $param[$i][$j], $string_evalformat);
  #         }
  #         $thisrow ++;
  #       }

  #       $Excelsheet->set_column($ABC[$column].':'.$ABC[$column], $column_size + 3);
  #       $column++;
  #     }
  #     else{
  #       for my $j (0 .. $#{$param[$i]}){
  #         my $num = scalar @{$param[$i][$j][1]};
  #         if($num == 1){
  #           $Excelsheet->set_column($ABC[$column].':'.$ABC[$column],20);
  #           $Excelsheet->set_row($row-1, 25);
  #           $Excelsheet->write($ABC[$column].$row, $param[$i][$j][0],$greenformat);
  #         }
  #         else{
  #           $Excelsheet->set_column($ABC[$column].':'.$ABC[$column+$num-1],10);
  #           $Excelsheet->merge_range($ABC[$column].$row.':'.$ABC[$column+$num-1].$row, $param[$i][$j][0],$greenformat);
  #         }

  #         for my $h(0 .. $#{$param[$i][$j][1]}){

  #           $Excelsheet->write($ABC[$column].($row+1), $param[$i][$j][1][$h][0],$blueformat);
  #           my $thisrow = $row + 2;
  #           for my $k(1 .. $#{$param[$i][$j][1][$h]}){
  #             if($param[$i][$j][1][$h][$k] =~ /^\d+(.\d+)?$/){
  #               $Excelsheet->write($ABC[$column].($thisrow), $param[$i][$j][1][$h][$k], $int_evalformat);
  #             }
  #             else{
  #               $Excelsheet->write($ABC[$column].($thisrow), $param[$i][$j][1][$h][$k], $string_evalformat);
  #             }
              
  #             $thisrow ++;
  #             # $evalformat->set_align('left');
  #           }
            
  #           $column++;
  #         }
  #       }
  #     }
      
  #   }
  #   # $row = ;
  # }
}

sub printExcel {
  my ($Excelsheet, $data , $location_value, $first, $deep ,$row, $column) = @_;
  my @location_value = @{$location_value};
  
  while(@location_value){
    if($location_value[0] =~ /^(\[(\d+\]\[\d+)\])\[\d+\].*/){
      my $int = $2;
      $int = quotemeta $int;
      my $first = $first;
      $first .= $1;

      my @new_location_value = ();
      while($location_value[0] =~ /^\[$int\]\[\d+\].*/){
        my $location_value_i = $location_value[0];
        $location_value_i =~ s/^\[\d+\]\[\d+\]\[\d+\]//;
        push @new_location_value, $location_value_i;
        shift @location_value;
      }

      my $name = eval('$data->'.$first.'[0]');
      if($row == 1){
        $$Excelsheet->merge_range($ABC[$$column].$row.':'.$ABC[$$column + @new_location_value - 1].$row , $name , $greenformat);
      }
      else{
        $$Excelsheet->merge_range($ABC[$$column].$row.':'.$ABC[$$column + @new_location_value - 1].$row , $name, $blueformat);
      }      
      printExcel( $Excelsheet, $data, \@new_location_value , "$first\[1\]" , $deep , $row + 1, $column);
    }
    else{
      my $thisrow = $deep - $row;      
      my $name = shift @location_value;
      my @printarray = @{eval('$data->' . $first . $name)};
      my $column_size = 0;
      my @str = split /\n/ , $printarray[0];
      for my $i (@str){
        if(length($i) > $column_size){
          $column_size = length($i);
        }
      }

      $$Excelsheet->set_row(1 , 50);

      if($thisrow == 0){
        $$Excelsheet->write($ABC[$$column].$row, $printarray[0], $blueformat);
      }
      else{
        $$Excelsheet->merge_range($ABC[$$column].$row.':'.$ABC[$$column].($row+$thisrow), $printarray[0], $blueformat);
      }
      for my $j (1 .. $#printarray){
        if( length($printarray[$j]) > $column_size ){          
          $column_size = length($printarray[$j]);
        }
        if($printarray[$j] =~ /^\d+(.\d+)?$/){
          $$Excelsheet->write($ABC[$$column].($deep+$j), $printarray[$j], $int_evalformat);
        }
        else{
          $$Excelsheet->write($ABC[$$column].($deep+$j), $printarray[$j], $string_evalformat);
        }
      }
      $$Excelsheet->set_column($ABC[$$column].':'.$ABC[$$column], $column_size + 3);
      $$column ++;
    }
  }
}
