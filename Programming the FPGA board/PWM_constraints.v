# 100MHz Main Clock
set_property -dict { PACKAGE_PIN G4    IOSTANDARD LVCMOS33 } [get_ports { clk }];
create_clock -period 10.000 -name clk [get_ports clk]

### ADC Clock
#set_property -dict { PACKAGE_PIN H14    IOSTANDARD LVCMOS33 } [get_ports { clk_adc1 }];

### DAC Clock
#set_property -dict { PACKAGE_PIN N10    IOSTANDARD LVCMOS33 } [get_ports { clk_dac1 }];
#set_property -dict { PACKAGE_PIN N1    IOSTANDARD LVCMOS33 } [get_ports { clk_dac2 }];
#set_property -dict { PACKAGE_PIN M2    IOSTANDARD LVCMOS33 } [get_ports { clk_dac3 }];

#####################################################################################
#####################################################################################
################################    MUX1  ###########################################
#							|	              Select		        |   	  Signal	   |
#							|_________________|_______________|                  |
#							|	     S1 	      |	     S0 	    |   	  Signal	   |
#							|_________________|_______________|                  |
#							|        0        |       0       |   	  	A0		   |
#							|        0        |       1       |   	  	A1		   |
#							|        1        |       0       |   	  	A2		   |
#							|        1        |       1       |   	  	A3		   |
#							|_________________|_______________|__________________|


################################    MUX1  ###########################################
#							|	             Select	    	      |   	  Signal	   |
#							|_________________|_______________|                  |
#							|	     S3 	      |	     S2 	    |   	  Signal	   |
#							|_________________|_______________|                  |
#							|        0        |       0       |     		A4		   |
#							|        0        |       1       |   	  	A5		   |
#							|        1        |       0       |   	  	A6		   |
#							|        1        |       1       |   	  	A7		   |
#							|_________________|_______________|__________________|


#####################################################################################
#####################################################################################
################################    MUX  ############################################
#set_property -dict { PACKAGE_PIN E12   IOSTANDARD LVCMOS33 } [get_ports { S[3] }]; 
#set_property -dict { PACKAGE_PIN F11   IOSTANDARD LVCMOS33 } [get_ports { S[2] }]; 
#set_property -dict { PACKAGE_PIN C12   IOSTANDARD LVCMOS33 } [get_ports { S[1] }]; 
#set_property -dict { PACKAGE_PIN E11   IOSTANDARD LVCMOS33 } [get_ports { S[0] }]; 



#####################################################################################
#####################################################################################
################################    ADC  ############################################
### ADC 1 constraints
#set_property -dict { PACKAGE_PIN A13   IOSTANDARD LVCMOS33 } [get_ports { adc_data1[9] }]; 
#set_property -dict { PACKAGE_PIN B13   IOSTANDARD LVCMOS33 } [get_ports { adc_data1[8] }]; 
#set_property -dict { PACKAGE_PIN B14   IOSTANDARD LVCMOS33 } [get_ports { adc_data1[7] }]; 
#set_property -dict { PACKAGE_PIN C14   IOSTANDARD LVCMOS33 } [get_ports { adc_data1[6] }]; 
#set_property -dict { PACKAGE_PIN D13   IOSTANDARD LVCMOS33 } [get_ports { adc_data1[5] }]; 
#set_property -dict { PACKAGE_PIN D14   IOSTANDARD LVCMOS33 } [get_ports { adc_data1[4] }]; 
#set_property -dict { PACKAGE_PIN E13   IOSTANDARD LVCMOS33 } [get_ports { adc_data1[3] }]; 
#set_property -dict { PACKAGE_PIN F14   IOSTANDARD LVCMOS33 } [get_ports { adc_data1[2] }]; 
#set_property -dict { PACKAGE_PIN F13   IOSTANDARD LVCMOS33 } [get_ports { adc_data1[1] }]; 
#set_property -dict { PACKAGE_PIN G14   IOSTANDARD LVCMOS33 } [get_ports { adc_data1[0] }];

### ADC 2 constraints
#set_property -dict { PACKAGE_PIN A2  IOSTANDARD LVCMOS33 } [get_ports { adc_data2[9] }]; 
#set_property -dict { PACKAGE_PIN B3  IOSTANDARD LVCMOS33 } [get_ports { adc_data2[8] }]; 
#set_property -dict { PACKAGE_PIN A3  IOSTANDARD LVCMOS33 } [get_ports { adc_data2[7] }]; 
#set_property -dict { PACKAGE_PIN A4   IOSTANDARD LVCMOS33 } [get_ports { adc_data2[6] }]; 
#set_property -dict { PACKAGE_PIN B5   IOSTANDARD LVCMOS33 } [get_ports { adc_data2[5] }]; 
#set_property -dict { PACKAGE_PIN A5   IOSTANDARD LVCMOS33 } [get_ports { adc_data2[4] }]; 
#set_property -dict { PACKAGE_PIN B6   IOSTANDARD LVCMOS33 } [get_ports { adc_data2[3] }]; 
#set_property -dict { PACKAGE_PIN B10   IOSTANDARD LVCMOS33 } [get_ports { adc_data2[2] }]; 
#set_property -dict { PACKAGE_PIN A10   IOSTANDARD LVCMOS33 } [get_ports { adc_data2[1] }]; 
#set_property -dict { PACKAGE_PIN A12   IOSTANDARD LVCMOS33 } [get_ports { adc_data2[0] }];

####################################################################################
####################################################################################
###############################    DAC  ############################################
### DAC 1 constraints
#set_property -dict { PACKAGE_PIN H13 IOSTANDARD LVCMOS33 } [get_ports { dac_data1[11] }]; 
#set_property -dict { PACKAGE_PIN J14 IOSTANDARD LVCMOS33 } [get_ports { dac_data1[10] }]; 
#set_property -dict { PACKAGE_PIN J13 IOSTANDARD LVCMOS33 } [get_ports { dac_data1[9] }]; 
#set_property -dict { PACKAGE_PIN L14 IOSTANDARD LVCMOS33 } [get_ports { dac_data1[8] }]; 
#set_property -dict { PACKAGE_PIN L13 IOSTANDARD LVCMOS33 } [get_ports { dac_data1[7] }]; 
#set_property -dict { PACKAGE_PIN M14 IOSTANDARD LVCMOS33 } [get_ports { dac_data1[6] }]; 
#set_property -dict { PACKAGE_PIN M13 IOSTANDARD LVCMOS33 } [get_ports { dac_data1[5] }]; 
#set_property -dict { PACKAGE_PIN N14 IOSTANDARD LVCMOS33 } [get_ports { dac_data1[4] }]; 
#set_property -dict { PACKAGE_PIN P13 IOSTANDARD LVCMOS33 } [get_ports { dac_data1[3] }]; 
#set_property -dict { PACKAGE_PIN P12 IOSTANDARD LVCMOS33 } [get_ports { dac_data1[2] }]; 
#set_property -dict { PACKAGE_PIN N11 IOSTANDARD LVCMOS33 } [get_ports { dac_data1[1] }]; 
#set_property -dict { PACKAGE_PIN P11 IOSTANDARD LVCMOS33 } [get_ports { dac_data1[0] }]; 

### DAC 2 constraints
#set_property -dict { PACKAGE_PIN J11 	IOSTANDARD LVCMOS33 } [get_ports { dac_data2[11] }]; 
#set_property -dict { PACKAGE_PIN K12   	IOSTANDARD LVCMOS33 } [get_ports { dac_data2[10] }]; 
#set_property -dict { PACKAGE_PIN L12   	IOSTANDARD LVCMOS33 } [get_ports { dac_data2[9] }]; 
#set_property -dict { PACKAGE_PIN M12  	IOSTANDARD LVCMOS33 } [get_ports { dac_data2[8] }]; 
#set_property -dict { PACKAGE_PIN M11 	IOSTANDARD LVCMOS33 } [get_ports { dac_data2[7] }]; 
#set_property -dict { PACKAGE_PIN K11   	IOSTANDARD LVCMOS33 } [get_ports { dac_data2[6] }]; 
#set_property -dict { PACKAGE_PIN M10  	IOSTANDARD LVCMOS33 } [get_ports { dac_data2[5] }]; 
#set_property -dict { PACKAGE_PIN P5   	IOSTANDARD LVCMOS33 } [get_ports { dac_data2[4] }]; 
#set_property -dict { PACKAGE_PIN P4  	IOSTANDARD LVCMOS33 } [get_ports { dac_data2[3] }]; 
#set_property -dict { PACKAGE_PIN N4   	IOSTANDARD LVCMOS33 } [get_ports { dac_data2[2] }]; 
#set_property -dict { PACKAGE_PIN P3   	IOSTANDARD LVCMOS33 } [get_ports { dac_data2[1] }]; 
#set_property -dict { PACKAGE_PIN P2  	IOSTANDARD LVCMOS33 } [get_ports { dac_data2[0] }];

### DAC 3 constraints
#set_property -dict { PACKAGE_PIN J2	 IOSTANDARD LVCMOS33 } [get_ports { dac3[11] }]; 
#set_property -dict { PACKAGE_PIN H1	 IOSTANDARD LVCMOS33 } [get_ports { dac3[10] }]; 
#set_property -dict { PACKAGE_PIN H2	 IOSTANDARD LVCMOS33 } [get_ports { dac3[9] }]; 
#set_property -dict { PACKAGE_PIN F2  IOSTANDARD LVCMOS33 } [get_ports { dac3[8] }]; 
#set_property -dict { PACKAGE_PIN F1  IOSTANDARD LVCMOS33 } [get_ports { dac3[7] }]; 
#set_property -dict { PACKAGE_PIN E2  IOSTANDARD LVCMOS33 } [get_ports { dac3[6] }]; 
#set_property -dict { PACKAGE_PIN G1  IOSTANDARD LVCMOS33 } [get_ports { dac3[5] }]; 
#set_property -dict { PACKAGE_PIN D1  IOSTANDARD LVCMOS33 } [get_ports { dac3[4] }]; 
#set_property -dict { PACKAGE_PIN D2  IOSTANDARD LVCMOS33 } [get_ports { dac3[3] }]; 
set_property -dict { PACKAGE_PIN C1  IOSTANDARD LVCMOS33 } [get_ports { pwm_out }]; 
#set_property -dict { PACKAGE_PIN B1  IOSTANDARD LVCMOS33 } [get_ports { dac3[1] }]; 
#set_property -dict { PACKAGE_PIN B2  IOSTANDARD LVCMOS33 } [get_ports { dac3[0] }];

####################################################################################
####################################################################################
###############################    Comparator  #####################################
#set_property -dict { PACKAGE_PIN G11 	IOSTANDARD LVCMOS33 } [get_ports { comp1 }]; 
#set_property -dict { PACKAGE_PIN H11  	IOSTANDARD LVCMOS33 } [get_ports { comp2 }]; 
#set_property -dict { PACKAGE_PIN H4   	IOSTANDARD LVCMOS33 } [get_ports { comp3 }]; 


####################################################################################
####################################################################################
###############################    Switches  ########################################
set_property -dict { PACKAGE_PIN M1   	IOSTANDARD LVCMOS33 } [get_ports { sw1 }];  #SW1
#set_property -dict { PACKAGE_PIN L2   	IOSTANDARD LVCMOS33 } [get_ports { switch1 }];  #SW2
#set_property -dict { PACKAGE_PIN L1   	IOSTANDARD LVCMOS33 } [get_ports { switch2 }];  #SW3
#set_property -dict { PACKAGE_PIN J1   	IOSTANDARD LVCMOS33 } [get_ports { switch3 }];  #SW4
#set_property -dict { PACKAGE_PIN K3   	IOSTANDARD LVCMOS33 } [get_ports { switch4 }];  #SW5


### Gate Signal constraints
#set_property -dict { PACKAGE_PIN D3  IOSTANDARD LVCMOS33 } [get_ports { pwm1 }];    #G0
#set_property -dict { PACKAGE_PIN C3  IOSTANDARD LVCMOS33 } [get_ports { pwm2 }];    #G1
#set_property -dict { PACKAGE_PIN C4  IOSTANDARD LVCMOS33 } [get_ports { pwm3 }];    #G2
#set_property -dict { PACKAGE_PIN D4  IOSTANDARD LVCMOS33 } [get_ports { pwm4 }];    #G3
#set_property -dict { PACKAGE_PIN C5  IOSTANDARD LVCMOS33 } [get_ports { pwm5 }];    #G4
#set_property -dict { PACKAGE_PIN E4  IOSTANDARD LVCMOS33 } [get_ports { pwm6 }];    #G5
#set_property -dict { PACKAGE_PIN D12 IOSTANDARD LVCMOS33 } [get_ports { pwm7 }];    #G6
#set_property -dict { PACKAGE_PIN F12 IOSTANDARD LVCMOS33 } [get_ports { pwm8 }];    #G7
#set_property -dict { PACKAGE_PIN F3  IOSTANDARD LVCMOS33 } [get_ports { pwm9 }];    #G8
#set_property -dict { PACKAGE_PIN H3  IOSTANDARD LVCMOS33 } [get_ports { pwm10 }];    #G9
#set_property -dict { PACKAGE_PIN F4  IOSTANDARD LVCMOS33 } [get_ports { pwm11 }];   #G10
#set_property -dict { PACKAGE_PIN H12 IOSTANDARD LVCMOS33 } [get_ports { pwm12 }];   #G11
#set_property -dict { PACKAGE_PIN J3  IOSTANDARD LVCMOS33 } [get_ports { pwm13 }];   #G12
#set_property -dict { PACKAGE_PIN J12 IOSTANDARD LVCMOS33 } [get_ports { pwm14 }];   #G13 
#set_property -dict { PACKAGE_PIN J4  IOSTANDARD LVCMOS33 } [get_ports { pwm15 }];   #G14 
#set_property -dict { PACKAGE_PIN L3  IOSTANDARD LVCMOS33 } [get_ports { pwm16 }];   #G15
#set_property -dict { PACKAGE_PIN K4  IOSTANDARD LVCMOS33 } [get_ports { pwm17 }];   #G16
#set_property -dict { PACKAGE_PIN L5  IOSTANDARD LVCMOS33 } [get_ports { pwm18 }];   #G17
#set_property -dict { PACKAGE_PIN P10 IOSTANDARD LVCMOS33 } [get_ports { pwm19 }];   #G18
#set_property -dict { PACKAGE_PIN M4  IOSTANDARD LVCMOS33 } [get_ports { pwm20 }];   #G19
#set_property -dict { PACKAGE_PIN M5  IOSTANDARD LVCMOS33 } [get_ports { pwm21 }];   #G20
#set_property -dict { PACKAGE_PIN M3  IOSTANDARD LVCMOS33 } [get_ports { pwm22 }];   #G21
