// =============================================================================
// -----------------------------------------------------------------------------
// Program
// -----------------------------------------------------------------------------

#include <stdio.h>
#include <windows.h>
#include <direct.h>

static const char InExt [] = { ".wav" };
static const char OutExt [] = { ".swf" };
static const char Folder [] = { "incswf" };
static int SampleRate = 22050;
static int Interpolation = 0x00;

const char *BoolString [] = { "FALSE", "TRUE" };
const char *FilterString [] = { "LINEAR", "AVERAGE", "FURTHEST", "TEST", NULL };

#define DEF_ALIGN 0x20

// =============================================================================
// -----------------------------------------------------------------------------
// Applying filter effect onto a low to high sample rate conversion
// -----------------------------------------------------------------------------

void FilterSample_Large (short *Channel, int &ChannelLoc, short *ChanOut, int &ChanOutLoc, int &ChanOutDest)

{
	int SampleA, SampleB, SampDist;
	if (Interpolation == 0x01)
	{
		// --- AVERAGE ---

		SampleA = Channel [ChannelLoc] << 0x0C;
		SampleB = Channel [++ChannelLoc] << 0x0C;
		SampDist = (SampleB - SampleA) / (ChanOutDest - ChanOutLoc);
		while (ChanOutLoc < ChanOutDest)
		{
			ChanOut [ChanOutLoc++] = SampleA >> 0x0C;
			SampleA += SampDist;
		}
	}
	else if (Interpolation == 0x02 || Interpolation == 0x03)
	{
		// --- FURTHEST ---

		SampleA = Channel [ChannelLoc];
		SampleA -= Channel [ChannelLoc + 1];
		SampleA /= 0x02;
		SampleA += Channel [++ChannelLoc];
		while (ChanOutLoc < ChanOutDest)
		{
			ChanOut [ChanOutLoc++] = SampleA;
		}
	}
	else
	{
		// --- LINEAR ---

		SampleA = Channel [++ChannelLoc];
		while (ChanOutLoc < ChanOutDest)
		{
			ChanOut [ChanOutLoc++] = SampleA;
		}
	}
}

// -----------------------------------------------------------------------------
// Applying filter effect onto a high to low sample rate conversion
// -----------------------------------------------------------------------------

void FilterSample_Smaller (short *Channel, int &ChannelLoc, int &ChannelDest, short *ChanOut, int &ChanOutLoc)

{
	int SampleA, SampleB, SampleBest, DivCount;
	int Sample = Channel [ChannelLoc];
	if (Interpolation == 0x01)
	{
		// --- AVERAGE ---

		SampleB = SampleA;
		for (DivCount = 1; ChannelLoc < ChannelDest; DivCount++)
		{
			SampleB += Channel [ChannelLoc++];
		}
		SampleB /= DivCount;
		ChanOut [ChanOutLoc++] = SampleB;
	}
	else if (Interpolation == 0x02)
	{

		// --- FURTHEST ---

		SampleB = 0;
		SampleBest = ChanOut [ChanOutLoc - 1];
		while (ChannelLoc < ChannelDest)
		{
			SampleA = Channel [ChannelLoc];
			SampleA += 0x8000;
			SampleA -= ChanOut [ChanOutLoc - 1] + 0x8000;
			if (SampleA < 0)
			{
				SampleA = -SampleA;
			}
			if (SampleA > SampleB)
			{
				SampleB = SampleA;
				SampleBest = Channel [ChannelLoc];
			}
			ChannelLoc++;
		}
		ChanOut [ChanOutLoc++] = SampleBest;
	}
	else if (Interpolation == 0x03)
	{
		int SampleSmall = 0x1000;
		int SampleBig = 0x0000;
		while (ChannelLoc < ChannelDest)
		{
			SampleA = Channel [ChannelLoc];
			if (SampleA < 0)
			{
				SampleA = -SampleA;
			}
			if (SampleA > SampleBig)
			{
				SampleBig = Channel [ChannelLoc];
			}
			else if (SampleA < SampleSmall)
			{
				SampleSmall = Channel [ChannelLoc];
			}
			ChannelLoc++;
		}
		SampleA = SampleSmall + ((SampleBig - SampleSmall) / 2);
		ChanOut [ChanOutLoc++] = SampleA;
	}
	else
	{
		// --- LINEAR ---

		ChanOut [ChanOutLoc++] = Channel [ChannelLoc];
		ChannelLoc = ChannelDest;
	}
}

// =============================================================================
// -----------------------------------------------------------------------------
// Subroutine to find an ASCII string within memory
// -----------------------------------------------------------------------------

int FindString (char *Memory, int MemorySize, const char *String)

{
	char Char;
	int EndLoc, StringLoc = -0x01, Count = -0x01;
	do
	{
		Count++;
		Char = String [++StringLoc];
	}
	while (Char != 0x00);
	if (Count == 0x00)
	{
		return (-0x01);
	}
	for (EndLoc = Count; EndLoc < MemorySize; EndLoc++)
	{
		Char = Memory [Count];
		Memory [Count] = 0x00;
		if (strcmp (Memory, String) == 0x00)
		{
			Memory [Count] = Char;
			return (EndLoc - Count);
		}
		Memory [Count] = Char;
		Memory++;
	}
	return (-0x01);
}

// =============================================================================
// -----------------------------------------------------------------------------
// Subroutine to check if a long-word ASCII string exists in an integer
// -----------------------------------------------------------------------------

bool CheckString (int Longword, const char *String)

{
	int Value = *String++ & 0xFF;
	Value |= (*String++ & 0xFF) << 0x08;
	Value |= (*String++ & 0xFF) << 0x10;
	Value |= (*String++ & 0xFF) << 0x18;
	if (Value == Longword)
	{
		return (TRUE);
	}
	return (FALSE);
}

// =============================================================================
// -----------------------------------------------------------------------------
// Subroutine to convert a hex represented decimal value to a hexadecimal value
// -----------------------------------------------------------------------------

int DecHex (unsigned int Decimal)

{
	int Hexadecimal = 0x00000000, DecimalDigit, HexadecimalPlaceLoc = 0x00000000;
	int HexadecimalPlace [] = {	1,
								10,
								100,
								1000,
								10000,
								100000,
								1000000,
								10000000,
								0x00 };
	while (Decimal > 0x99999999)
	{
		Decimal = 0x99999999;
	}
	while (HexadecimalPlace [HexadecimalPlaceLoc] != 0x00)
	{
		DecimalDigit = Decimal & 0x0F;
		Decimal >>= 0x04;
		while (DecimalDigit != 0x00)
		{
			Hexadecimal += HexadecimalPlace [HexadecimalPlaceLoc];
			DecimalDigit--;
		}
		HexadecimalPlaceLoc++;
	}
	return (Hexadecimal);
}

// =============================================================================
// -----------------------------------------------------------------------------
// Main Routine
// -----------------------------------------------------------------------------

int main (int ArgNumber, char **ArgList, char **EnvList)

{
	printf ("Convert PCM - by MarkeyJester\n\n");
	if (ArgNumber <= 0x01)
	{
		printf (" -> Arguments: ConvPCM.exe Input01%s Input02%s Input03%s etc...\n\n", InExt, InExt, InExt);
		printf ("    Simply drag and drop %s files onto this program to convert\n", InExt);
		printf ("    to %s\n\n", OutExt);
		printf (" -> This program will convert wave files of varying types into\n");
		printf ("    raw PCM 255-Byte Mono format, suitable for Dual PCM - FlexEd\n\n", OutExt);
		printf ("    If a raw binary ROM is passed to this program, it shall be treated\n");
		printf ("    as an unsigned 8-bit mono sample, the rate of this sample shall not\n");
		printf ("    be changed, as the rate is also unknown.\n");
		printf ("\nPress enter key to exit...\n");
		fflush (stdin);
		getchar ( );
		return (0x00);
	}
	int ArgCount, DirectLoc;
	char Direct [0x1000], Char, *FileName, *ExtName;
	char OutName [0x1000];

	FILE *File = fopen ("ConvPCM.txt", "r");
	if (File == NULL)
	{
		printf ("    Error; could not open \"ConvPCM.txt\" settings file\n");
		printf ("\nPress enter key to exit...\n");
		fflush (stdin);
		getchar ( );
		return (0x00);
	}
	fseek (File, 0x00, SEEK_END);
	int FileSize = ftell (File);
	rewind (File);
	char Line [0x1000];
	char Entry [0x1000];
	while (ftell (File) < FileSize)
	{
		fgets (Line, 0x1000, File);
		int LineLoc = 0x00;
		for ( ; ; )
		{
			do
			{
				Char = Line [LineLoc++];
			}
			while (Char == '	' || Char == ' ');
			if (Char != 0x0D && Char != 0x0A && Char != 0x00)
			{
				int EntryLoc = 0x00;
				while (Char != ':' && Char != 0x0D && Char != 0x0A && Char != 0x00)
				{
					Entry [EntryLoc++] = Char;
					Char = Line [LineLoc++];
				}
				Entry [EntryLoc++] = 0x00;
				if ((strcmp (Entry, "Sample Rate")) == 0x00)
				{
					do
					{
						Char = Line [LineLoc++];
					}
					while ((Char < '0' || Char > '9') && Char != 0x0D && Char != 0x0A && Char != 0x00);
					if (Char != 0x0D && Char != 0x0A && Char != 0x00)
					{
						SampleRate = 0;
						while (Char >= '0' && Char <= '9')
						{
							SampleRate = (SampleRate << 0x04) | ((Char - '0') & 0x0F);
							Char = Line [LineLoc++];
						}
						SampleRate = DecHex (SampleRate);
					}
				}
				else if ((strcmp (Entry, "Interpolation")) == 0x00)
				{
					do
					{
						Char = Line [LineLoc++];
					}
					while (Char == '	' || Char == ' ');
					if (Char != 0x0D && Char != 0x0A && Char != 0x00)
					{
						char *StringLoc = Line + (LineLoc - 0x01);
						while (Char != '	' && Char != ' ' && Char != 0x0D && Char != 0x0A && Char != 0x00)
						{
							Char = Line [LineLoc++];
						}
						Line [LineLoc - 0x01] = 0x00;
						for (Interpolation = 0x00; FilterString [Interpolation] != NULL; Interpolation++)
						{
							if ((strcmp (StringLoc, FilterString [Interpolation])) == 0x00)
							{
								break;
							}
						}
						if (FilterString [Interpolation] == NULL)
						{
							printf ("    Error; Interpolation set as \"%s\"\n", StringLoc);
							printf ("    It can only be the following:\n\n");
							for (Interpolation = 0x00; FilterString [Interpolation] != NULL; Interpolation++)
							{
								printf ("      %s\n", FilterString [Interpolation]);
							}
							Interpolation = 0x00;
							printf ("\n    Press enter key to continue...\n");
							fflush (stdin);
							getchar ( );
						}

					/*	if ((strcmp (StringLoc, BoolString [0])) == 0x00)
						{
							Interpolation = FALSE;
						}
						else if ((strcmp (StringLoc, BoolString [1])) == 0x00)
						{
							Interpolation = TRUE;
						}
						else
						{
							printf ("    Error; Interpolation set as \"%s\"\n", StringLoc);
							printf ("    Must be \"TRUE\" or \"FALSE\" (full capitals)\n");
							printf ("    Press enter key to continue...\n");
							fflush (stdin);
							getchar ( );
						}	*/
					}
				}
				else
				{
					printf ("    Error; unknown setting \"%s\"\n", Entry);
					printf ("    Press enter key to continue...\n");
					fflush (stdin);
					getchar ( );
				}
			}
			break;
		}
	}
	fclose (File);
	printf ("    Final Sample rate: %3d.%0.3d kHz\n", SampleRate / 1000, SampleRate % 1000);
	printf ("    Interpolation:        %s\n\n", FilterString [Interpolation]);
	mkdir (Folder);

	// --- File Read Loop ---

	for (ArgCount = 0x01; ArgCount < ArgNumber; ArgCount++)
	{

		// --- Filename ---

		FileName = Direct;
		ExtName = NULL;
		DirectLoc = -0x01;
		do
		{
			Char = ArgList [ArgCount] [++DirectLoc];
			if (Char == '\\' || Char == '/')
			{
				FileName = Direct + (DirectLoc + 0x01);
			}
			else if (Char == '.')
			{
				ExtName = Direct + DirectLoc;
			}
			Direct [DirectLoc] = Char;
		}
		while (Char != 0x00);
		if (ExtName == NULL)
		{
			ExtName = Direct + DirectLoc;
		}
		printf (" -> %s\n", FileName);
	/*	if (strcmp (ExtName, InExt) != 0x00)
		{
			printf ("    Error; the file's extension name must be %s\n", InExt);
			printf ("    Press enter key to continue...\n");
			fflush (stdin);
			getchar ( );
			continue;
		}	*/

		bool NonWave = FALSE;
		if (strcmp (ExtName, InExt) != 0x00)
		{
			NonWave = TRUE;
		}

		// --- Loading file ---

		if ((File = fopen (Direct, "rb")) == NULL)
		{
			printf ("    Error; could not open the file\n");
			printf ("    Press enter key to continue...\n");
			fflush (stdin);
			getchar ( );
			continue;
		}
		fseek (File, 0x00, SEEK_END);
		int InputSize = ftell (File);
		char *Input = (char*) malloc (InputSize);
		if (Input == NULL)
		{
			fclose (File);
			printf ("    Error; could not allocate memory for input file\n");
			printf ("    Press enter key to continue...\n");
			fflush (stdin);
			getchar ( );
			continue;
		}
		rewind (File);
		fread (Input, 0x01, InputSize, File);
		fclose (File);

		// --- Varifying file ---

		int InputChan, InputRate, InputBits;
		int SampleSize;
		char *Sample;

		if (NonWave == FALSE)
		{
			if (FindString (Input, InputSize, "RIFF") == -0x01)
			{
				free (Input);
				printf ("    Error; could not find \"RIFF\" descriptor\n");
				printf ("    Press enter key to continue...\n");
				fflush (stdin);
				getchar ( );
				continue;
			}
			int *InputInt = (int*) Input;
			if ((InputInt [0x01] + 0x08) > InputSize)
			{
				free (Input);
				printf ("    Error; the chunk size is larger than the file, it may be corrupt\n");
				printf ("    Press enter key to continue...\n");
				fflush (stdin);
				getchar ( );
				continue;
			}
			int InputLoc = FindString (Input, InputSize, "WAVE");
			if (InputLoc == -0x01)
			{
				free (Input);
				printf ("    Error; could not find \"WAVE\" descriptor\n");
				printf ("    Press enter key to continue...\n");
				fflush (stdin);
				getchar ( );
				continue;
			}
			InputInt = (int*) (Input + InputLoc);
			if (CheckString (InputInt [0x01], "fmt ") == FALSE)
			{
				free (Input);
				printf ("    Error; could not find \"fmt \" descriptor\n");
				printf ("    Press enter key to continue...\n");
				fflush (stdin);
				getchar ( );
				continue;
			}
			InputChan = InputInt [0x03];
			InputRate = InputInt [0x04];
			InputBits = (InputInt [0x06] >> 0x10) & 0xFFFF;
			if ((InputChan & 0xFFFF) != 0x01)
			{
				free (Input);
				printf ("    Error; this wave format is compress in a certain way, cannot convert\n");
				printf ("    Press enter key to continue...\n");
				fflush (stdin);
				getchar ( );
				continue;
			}
			InputChan = (InputChan >> 0x10) & 0xFFFF;
			InputLoc = FindString (Input, InputSize, "data");
			if (InputLoc == -0x01)
			{
				free (Input);
				printf ("    Error; could not find \"data\" descriptor\n");
				printf ("    Press enter key to continue...\n");
				fflush (stdin);
				getchar ( );
				continue;
			}
			InputInt = (int*) (Input + InputLoc);
			SampleSize = InputInt [0x01];
			Sample = Input + (InputLoc + 0x08);
		}
		else
		{
			InputChan = 1;
			InputRate = SampleRate;
			InputBits = 8;
			SampleSize = InputSize;
			Sample = Input;
		}

		printf ("    Bits Per Sample:    %6d\n", InputBits);
		printf ("    Sample rate:       %3d.%0.3d kHz\n", InputRate / 1000, InputRate % 1000);
		printf ("    Channels:           %6d\n", InputChan);
		printf ("    Samples:          %8X\n", ((SampleSize / InputChan) / (InputBits / 8)));

		char Mode = 0x00;
		if (InputBits > 8)
		{
			Mode += 1;
		}
		if (InputChan != 1)
		{
			Mode += 2;
		}

		// --- Converting to 16-bit signed stereo for rate change ---

		int ChannelSize = ((SampleSize / InputChan) / (InputBits / 8));
		short *ChannelL = (short*) malloc ((ChannelSize + 1) * sizeof (short));
		short *ChannelR = (short*) malloc ((ChannelSize + 1) * sizeof (short));
		if (ChannelL == NULL || ChannelR == NULL)
		{
			free (Input);
			printf ("    Error; could not allocate memory for left/right channels\n");
			printf ("    Press enter key to continue...\n");
			fflush (stdin);
			getchar ( );
			continue;
		}
		int ChannelLoc, SampleLoc = 0x00;
		int SampleA, SampleB;
		switch (Mode)
		{
			case 0: // Mono 8
			{
				for (ChannelLoc = 0x00; ChannelLoc < ChannelSize; ChannelLoc++)
				{
					Char = Sample [SampleLoc++] + 0x80;
					SampleA = Char << 0x08;
					ChannelL [ChannelLoc] = SampleA;
					ChannelR [ChannelLoc] = SampleA;
				}
				ChannelL [ChannelLoc] = SampleA;
				ChannelR [ChannelLoc] = SampleA;
			}
			break;
			case 1: // Mono 16
			{
				for (ChannelLoc = 0x00; ChannelLoc < ChannelSize; ChannelLoc++)
				{
					SampleA = Sample [SampleLoc++] & 0xFF;
					SampleA |= Sample [SampleLoc++] << 0x08;
					ChannelL [ChannelLoc] = SampleA;
					ChannelR [ChannelLoc] = SampleA;
				}
				ChannelL [ChannelLoc] = SampleA;
				ChannelR [ChannelLoc] = SampleA;
			}
			break;
			case 2: // Stereo 8
			{
				for (ChannelLoc = 0x00; ChannelLoc < ChannelSize; ChannelLoc++)
				{
					Char = Sample [SampleLoc++] + 0x80;
					SampleA = Char << 0x08;
					ChannelL [ChannelLoc] = SampleA;
					Char = Sample [SampleLoc++] + 0x80;
					SampleB = Char << 0x08;
					ChannelR [ChannelLoc] = SampleB;
				}
				ChannelL [ChannelLoc] = SampleA;
				ChannelR [ChannelLoc] = SampleB;
			}
			break;
			case 3: // Stereo 16
			{
				for (ChannelLoc = 0x00; ChannelLoc < ChannelSize; ChannelLoc++)
				{
					SampleA = Sample [SampleLoc++] & 0xFF;
					SampleA |= Sample [SampleLoc++] << 0x08;
					ChannelL [ChannelLoc] = SampleA;
					SampleB = Sample [SampleLoc++] & 0xFF;
					SampleB |= Sample [SampleLoc++] << 0x08;
					ChannelR [ChannelLoc] = SampleB;
				}
				ChannelL [ChannelLoc] = SampleA;
				ChannelR [ChannelLoc] = SampleB;
			}
			break;
		}
		free (Input); Input = NULL;

		// --- Changing rate ---

		int OutputRate = SampleRate;

		short *ChanOutL, *ChanOutR;
		int ChanOutLoc, ChanOutSize;

		if (InputRate == OutputRate)
		{
			// --- No rate change ---

			ChanOutSize = ChannelSize;
			ChanOutL = (short*) malloc (ChanOutSize * sizeof (short));
			ChanOutR = (short*) malloc (ChanOutSize * sizeof (short));
			for (ChannelLoc = 0x00; ChannelLoc < ChannelSize; ChannelLoc++)
			{
				ChanOutL [ChannelLoc] = ChannelL [ChannelLoc];
				ChanOutR [ChannelLoc] = ChannelR [ChannelLoc];
			}
		}
		else if (OutputRate > InputRate)
		{
			// --- Rate change to larger ---

			int AdvanceRate = (OutputRate * 1000) / InputRate;
			int AdvanceCur, ChanOutDest, SampDist;

			ChanOutSize = 0x20000;
			ChanOutL = (short*) malloc (ChanOutSize * sizeof (short));

			ChannelLoc = 0x00;
			ChanOutLoc = 0x00;
			AdvanceCur = 0x00;
			ChanOutDest = 0x00;
			while (ChannelLoc < ChannelSize)
			{
				if (ChanOutLoc > (ChanOutSize - 0x10000))
				{
					ChanOutSize += 0x10000;
					short *ChanOutNew = (short*) realloc (ChanOutL, ChanOutSize * sizeof (short));
					if (ChanOutNew == NULL)
					{
						printf ("    Error; reallocation issue\n");
						printf ("    Press enter key to exit...\n");
						fflush (stdin);
						getchar ( );
						return (0x00);
					}
					ChanOutL = ChanOutNew;
				}
				AdvanceCur += AdvanceRate;
				ChanOutDest += (AdvanceCur / 1000);
				AdvanceCur %= 1000;
				FilterSample_Large (ChannelL, ChannelLoc, ChanOutL, ChanOutLoc, ChanOutDest);
			}

			ChanOutSize = 0x20000;
			ChanOutR = (short*) malloc (ChanOutSize * sizeof (short));

			ChannelLoc = 0x00;
			ChanOutLoc = 0x00;
			AdvanceCur = 0x00;
			ChanOutDest = 0x00;
			while (ChannelLoc < ChannelSize)
			{
				if (ChanOutLoc > (ChanOutSize - 0x10000))
				{
					ChanOutSize += 0x10000;
					short *ChanOutNew = (short*) realloc (ChanOutR, ChanOutSize * sizeof (short));
					if (ChanOutNew == NULL)
					{
						printf ("    Error; reallocation issue\n");
						printf ("    Press enter key to exit...\n");
						fflush (stdin);
						getchar ( );
						return (0x00);
					}
					ChanOutR = ChanOutNew;
				}
				AdvanceCur += AdvanceRate;
				ChanOutDest += (AdvanceCur / 1000);
				AdvanceCur %= 1000;
				FilterSample_Large (ChannelR, ChannelLoc, ChanOutR, ChanOutLoc, ChanOutDest);
			}
			ChanOutSize = ChanOutLoc;
		}
		else
		{
			// --- Rate change to smaller ---

			int AdvanceRate = (InputRate * 1000) / OutputRate;
			int AdvanceCur, ChannelDest, DivCount;

			ChanOutSize = 0x20000;
			ChanOutL = (short*) malloc (ChanOutSize * sizeof (short));

			ChannelLoc = 0x00;
			ChanOutLoc = 0x00;
			ChanOutL [ChanOutLoc++] = ChannelL [ChannelLoc];

			AdvanceCur = 0x00;
			ChannelDest = 0x00;
			while (ChannelLoc < ChannelSize)
			{
				if (ChanOutLoc > (ChanOutSize - 0x10000))
				{
					ChanOutSize += 0x10000;
					short *ChanOutNew = (short*) realloc (ChanOutL, ChanOutSize * sizeof (short));
					if (ChanOutNew == NULL)
					{
						printf ("    Error; reallocation issue\n");
						printf ("    Press enter key to exit...\n");
						fflush (stdin);
						getchar ( );
						return (0x00);
					}
					ChanOutL = ChanOutNew;
				}
				AdvanceCur += AdvanceRate;
				ChannelDest += (AdvanceCur / 1000);
				AdvanceCur %= 1000;

				FilterSample_Smaller (ChannelL, ChannelLoc, ChannelDest, ChanOutL, ChanOutLoc);

			}

			ChanOutSize = 0x20000;
			ChanOutR = (short*) malloc (ChanOutSize * sizeof (short));

			ChannelLoc = 0x00;
			ChanOutLoc = 0x00;
			ChanOutR [ChanOutLoc++] = ChannelR [ChannelLoc];

			AdvanceCur = 0x00;
			ChannelDest = 0x00;
			while (ChannelLoc < ChannelSize)
			{
				if (ChanOutLoc > (ChanOutSize - 0x10000))
				{
					ChanOutSize += 0x10000;
					short *ChanOutNew = (short*) realloc (ChanOutR, ChanOutSize * sizeof (short));
					if (ChanOutNew == NULL)
					{
						printf ("    Error; reallocation issue\n");
						printf ("    Press enter key to exit...\n");
						fflush (stdin);
						getchar ( );
						return (0x00);
					}
					ChanOutR = ChanOutNew;
				}
				AdvanceCur += AdvanceRate;
				ChannelDest += (AdvanceCur / 1000);
				AdvanceCur %= 1000;

				FilterSample_Smaller (ChannelR, ChannelLoc, ChannelDest, ChanOutR, ChanOutLoc);

			/*	SampleA = ChannelR [ChannelLoc];
				SampleB = SampleA;
				for (DivCount = 1; ChannelLoc < ChannelDest; DivCount++)
				{
					SampleB += ChannelR [ChannelLoc++];
				}
				if (Interpolation == 0x01)
				{
					SampleB /= DivCount;
					ChanOutR [ChanOutLoc++] = SampleB;	// Interpolated
				}
				else
				{
					ChanOutR [ChanOutLoc++] = SampleA;	// Linear
				}	*/
			}
			ChanOutSize = ChanOutLoc;
		}

		free (ChannelL);
		free (ChannelR);

		// --- Converting to mono 8-bit signed ---

		int OutputSize = ChanOutSize;
		char *Output = (char*) malloc (OutputSize);
		if (Output == NULL)
		{
			printf ("    Error; could not allocate memory for output file\n");
			printf ("    Press enter key to continue...\n");
			fflush (stdin);
			getchar ( );
			continue;
		}
		int OutputLoc;

		// 16-bit sample is broken into quotient and dividend (QQDD)
		// The correct way to convert to 8-bit from a mathematical point of
		// view, is to round the quotient up or down based on the dividend.
		// If the dividend is 80 - FF, round up, otherwise, round down.

		// --- The method used here is somewhat different however ---

		// The quotient is rounded up or down based on its polarity instead.
		// If the quotient is positive, then it's ALWAYS rounded down.
		// If the quotient is negative, then it's rounded up if the dividend is NOT 0.

		// 0140 becomes 0100 | 02F5 becomes 0200 | 4829 becomes 4800
		// FE24 becomes FF00 | FC00 becomes FC00 | A384 becomes A400

		// The method below is technically incorrect, but, it does have an
		// interesting side effect.  This causes all silent noises to mute
		// out, reducing quantisation noise on near silent sounds.

		for (OutputLoc = 0x00, ChanOutLoc = 0x00; ChanOutLoc < ChanOutSize; ChanOutLoc++)
		{
			SampleA = ChanOutL [ChanOutLoc];
			SampleA += ChanOutR [ChanOutLoc];
			SampleA >>= 0x01;
			if (SampleA < 0x0000)
			{
				if ((SampleA & 0x00FF) != 0x00)
				{
					SampleA += 0x0100;
				}
			}
			SampleA = (SampleA >> 0x08) & 0xFF;
			SampleA = (SampleA << 0x18) >> (0x18 + 0x00);	// set 0x00 to 0x01 to divide it by 2
			SampleA += 0x80;				// convert to unsigned
			if (SampleA == 0x00)
			{
				SampleA++;
			}
			Output [OutputLoc++] = SampleA;
		}

		// --- Saving file ---

		strcpy (ExtName, OutExt);
		strcpy (OutName, FileName);
		FileName += snprintf (FileName, 0x1000, "%s\\", Folder);
		strcpy (FileName, OutName);
		if ((File = fopen (Direct, "wb")) == NULL)
		{
			free (Output);
			printf ("    Error; could not create \"%s\"\n", FileName);
			printf ("    Press enter key to continue...\n");
			fflush (stdin);
			getchar ( );
			continue;
		}
		fwrite (Output, 0x01, OutputSize, File);
		fclose (File);

		// --- Finish ---

		free (Output); Output = NULL;

		printf ("\n");
	}
	printf ("Press enter key to exit...\n");
	fflush (stdin);
	getchar ( );
}

// =============================================================================
