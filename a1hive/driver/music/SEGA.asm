	sHeaderInit
	sHeaderTempo	$01, $00
	sHeaderCh	$00, $00
	sHeaderDAC	.DAC1, $00, dSega
	sHeaderDAC	.DAC2, $00, $00

.DAC1	sComm	0, $00		; indicate sample is playing
	dc.b nC4, $7F		; C4 is the base pitch (pitch $100) note for DAC
	sComm	0, $01		; indicate sample has ended
.DAC2	sStop
