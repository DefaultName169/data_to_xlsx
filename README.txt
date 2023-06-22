sử dụng @param dưới dạng

nếu trong hash data có key thì trong param gọi theo dạng {key}
VD : trong hash data có key là 'ip' thì value của key đó là {ip}

cách viết trong param

['<tên cell>'           ,'<eval>']

VD: 
  Instance có giá trị : $word . 'x' . $io . 'm' . $mux
  param có dạng : 
  ['Instance'       , '{word} . \'x\' . {io} . \'m\' . {mux}']

nếu muốn lấy nhiều giá trị cũng 1 loại định dạng sử dụng param kiểu

['[$title]', '<tên muốn đặt cho từng cell>',
            [
                param muốn lấy bên trong
            ],
  '<mảng giá trị muốn lấy>'
]

VD:   
['[$title]', '$this:{param}->{p} . \'/\' . $this:{param}->{vol} . \'V/\' . $this:{param}->{temp} . \'C\'',
            [  
              ["Speed\n(MHz)"                   , '$this:{param}->{hz}'],
              ["Access\ntime\n(ps)"             , '( {$this:{param}->{process}}->{vals}:{param}->{load} == 0 ) && ( {$this:{param}->{process}}->{vals}:{param}->{process} eq $this:{param}->{pin})'
                                                , '$this:{param}->{taa}'],
            ],
  '{max}->{vals}'
]

Data trong database 

max 
====================================================
process     p        temp   vol   mhz       pin        <------ param
---------   -----   ----  -----   -------   ---------
T_RWM(011)     tt     85  0.750   4618.94     tt85trv  <------- val->[0]
T_RWM(011)  ssgnp    125  0.675   3637.69   ssgnp125c  <------- val->[1]
T_RWM(011)  ssgnp    -40  0.675   3106.55   ssgnpn40c  <------- val->[2]
*****************************************************

param[0]: luôn để là [$title]
param[1]: $this:{param}->{p}  : $this là từng giá trị của {max}->{val}
                                :{param}->{p} những giá trị đấy lấy param p
                                
param[2]: luôn là mảng
          param[2][1][1] : ( {$this:{param}->{process}}->{vals}:{param}->{load} == 0 )...
                            $this là từng giá trị của param[3] {max}->{val}
                            
                            ({$this:{param}->{process}}->{vals}:{param}->{load} == 0 )..
                            phân tích :
                                + $this hiện tại là val->[0]
                                + $this:{param}->{process}: T_RWM(011)
                                + => {T_RWM(011)}->{vals}:{param}->{load} == 0 
                                + tương tự => ({T_RWM(011)}->{vals}:{param}->{load} == 0 ) && ({T_RWM(011)}->{vals}:{param}->{process} eq {max}->{val}:{param}->{pin})
                                       lấy phần tử tại bảng  T_RWM(011) có load == 0 && T_RWM(011) có process == 'tt85trv'
                                         
                                       T_RWM(011)       
                                        =============================================
                                        Process    Load    Tcc    Taa    Toch   Slope
                                        Corner     (fF)    (pS)   (pS)   (pS)   (pS) 
                                        ---------  ------ ------ ------ ------ ------
                                        typ           0.0  220.8  139.4   92.5    3.2   
                                        typ          50.0  221.9  165.7   92.5   47.7

                                        ssgnpn40c     0.0  322.0  212.4  144.9    3.9   
                                        ssgnpn40c    50.0  322.7  243.4  144.9   52.2

                                        ffgnp125c     0.0  180.7  108.8   69.8    3.1   
                                        ffgnp125c    50.0  181.6  133.7   69.8   46.4

                                        tt85trv       0.0  216.5  134.3   88.4    3.4   <- $this của param[2][1][2] 
                                        tt85trv      50.0  217.4  161.0   88.4   48.1

                                        ssgnp125c     0.0  274.8  172.4  115.4    4.3
                                        ssgnp125c    50.0  275.5  203.0  115.4   52.8

                                        ssgnp0c       0.0  306.8  200.7  136.7    4.0
                                        ssgnp0c      50.0  308.8  231.4  136.7   52.3
                                        *********************************************
                                        
          param[2][1][2] :  $this:{param}->{taa} = 134.3

param[3]: {max}->{val}      : giá trị muốn lấy là data->{max}->{val}











