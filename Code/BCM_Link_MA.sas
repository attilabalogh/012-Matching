/*  -------------------------------------------------------------------------  */
/*                                                                             */
/*               Data matching for corporate governance research               */
/*                                                                             */
/*  Program      : BCM_Link_MA.sas                                             */
/*  Author       : Attila Balogh, School of Banking and Finance                */
/*                 UNSW Business School, UNSW Sydney                           */
/*  Date Created : 15 Oct 2017                                                 */
/*  Last Modified: 22 Dec 2017                                                 */
/*                                                                             */
/*  Description  : BoardEx data to Comustat GVKEY manual matching step         */
/*                                                                             */
/*  Notes        : Please reference the following paper when using this code   */
/*                 Balogh, A 2017                                              */
/*                 Data matching for corporate governance research             */
/*                 Available at SSRN: https://ssrn.com/abstract=3053405        */
/*                                                                             */
/*  _________________________________________________________________________  */

/*  NR - No link available, confirmed by research */

data A_13_set_00;
	set Boardex.Na_dir_profile_emp;
	rename CompanyID = BoardID;
	rename CompanyName = BoardName;
	keep CompanyID CompanyName ;
run;
proc sort data=A_13_set_00 nodupkey ;
	by BoardID BoardName;
run;


data AB_App_13 BX_Link.AB_App_13;
	set A_13_set_00;
/*	set boardex.Na_company_profile_details;*/
	if BoardID in(15917) then gvkey = '116609';	/*  INFINITY BROADCASTING CORP */
	if BoardID in(678) then gvkey = '031520';		/*	ACRODYNE COMMUNICATIONS INC  */
	if BoardID in(3342) then gvkey = '065196';	/*	AZUREL	*/
	if BoardID in(5816) then gvkey = '062912';	/*	CARDIOGENESIS CORP (Eclipse Surgical Technologies prior to 05/2001) (De-listed 04/2003)	 */
/*	if BoardID in(10302) then gvkey = '004252';*/	/*	ELDER-BEERMAN STORES CORP (De-listed 10/2003)	*/
	if BoardID in(10302) then gvkey = '066465';	/*	ELDER-BEERMAN STORES CORP (De-listed 10/2003)	*/
	if BoardID in(10447) then gvkey = '130400';	/*	ELOQUENT INC */
	if BoardID in(10633) then gvkey = '062200';	/*	ENDOCARE INC (De-listed 07/2009)	*/
	if BoardID in(15272) then gvkey = '065825';	/*	HYBRID NETWORKS INC (De-listed 04/2002)	*/
	if BoardID in(15625) then gvkey = '126495';	/*	IMANAGE INC */
/*	10*/
	if BoardID in(15835) then gvkey = '005921';	/*	INDIANAPOLIS POWER & LIGHT CO */
	if BoardID in(19318) then gvkey = '163087';	/*	SOLEXA INC (Lynx Therapeutics prior to 2/2005) (De-listed 01/2007) */
	if BoardID in(27921) then gvkey = '009691';	/*	SIERRA PACIFIC POWER CO */
	if BoardID in(29259) then gvkey = '009900';	/*	SOUTHWESTERN BELL TELEPHONE CO */
	if BoardID in(29310) then gvkey = '010093';	/*	STONE CONTAINER CP */
	if BoardID in(32064) then gvkey = '022915';	/*	US-WORLDLINK INC */
	if BoardID in(634006) then gvkey = '108107';	/*	BUCHANS MINERALS CORP (Royal Roads Corp prior to 07/2010) (De-listed 07/2013) */
	if BoardID in(634381) then gvkey = '026355';	/*	PETAQUILLA MINERALS LTD (Adrian Resources Ltd prior to 12/2004) (De-listed 03/2015) */
	if BoardID in(741484) then gvkey = '107860';	/*	CANICKEL MINING LTD (Crowflight Minerals Inc prior to 06/2011) */
	if BoardID in(784170) then gvkey = '107758';	/*	VANGOLD RESOURCES LTD */
/*	20*/
	if BoardID in(815929) then gvkey = '148810';	/*	ALBA MINERALS LTD (Acrex Ventures Ltd prior to 07/2014) CANADIAN */
	if BoardID in(917913) then gvkey = '108292';	/*	DAMARA GOLD CORP (Solomon Resources Ltd prior to 10/2014) */
	if BoardID in(933187) then gvkey = '107962';	/*	ALDERSHOT RESOURCES LTD (Quattro Resources Ltd prior to 10/2001) */
	if BoardID in(1003662) then gvkey = '106064';	/*	EL NINO VENTURES INC */
	if BoardID in(1055313) then gvkey = '107854';	/*	PETROMIN RESOURCES LTD */
	if BoardID in(1095421) then gvkey = '106968';	/*	KENAI RESOURCES LTD (De-listed 07/2013) */
	if BoardID in(1147989) then gvkey = '105826';	/*	CASSIDY GOLD CORP (PMA Resources Inc prior to 09/1996) (De-listed 06/2017) */
	if BoardID in(1210869) then gvkey = '183274';	/*	BAYMOUNT INC (Academy Capital Corp prior to 01/2006) */
	if BoardID in(1221966) then gvkey = '142933';	/*	MOUNTAINVIEW ENERGY LTD */
	if BoardID in(1222852) then gvkey = '142501';	/*	MAXTECH VENTURES INC */
/*	30*/
	if BoardID in(1226178) then gvkey = '106008';	/*	XEMPLAR ENERGY CORP (Consolidated Petroquin Resources Ltd prior to 07/07/2005) */
	if BoardID in(1227073) then gvkey = '065809';	/*	FUTURE FARM TECHNOLOGIES INC (Arcturus Growthstar Technologies Inc prior to 02/2017) */
	if BoardID in(1245334) then gvkey = '177472';	/*	NOBILIS HEALTH CORP (Northstar Healthcare Inc prior to 12/2014) */
	if BoardID in(1262284) then gvkey = '155462';	/*	SEAIR INC */
	if BoardID in(1281699) then gvkey = '106988';	/*	BELLHAVEN COPPER & GOLD INC (Bellhaven Ventures Inc prior to 10/2006) (De-listed 05/2017) */
	if BoardID in(1347626) then gvkey = '178326';	/*	ELGIN MINING INC (Phoenix Coal Inc prior to 05/2010) */
	if BoardID in(1623978) then gvkey = '137840';	/*	IROC ENERGY SERVICES CORP (IROC Systems Corp prior to 05/2007) (De-listed 04/2013) */
	if BoardID in(1684863) then gvkey = '140202';	/*	HORNBY BAY MINERAL EXPLORATION LTD (HBME) (UNOR Inc prior to 04/2010) */
	if BoardID in(1713074) then gvkey = '187583';	/*	BRAVURA VENTURES CORP */
	if BoardID in(1248) then gvkey = '001225';		/*	ALABAMA POWER CO	*/
/*	40*/
	if BoardID in(1738) then gvkey = '023253';	/*	RADIENT PHARMACEUTICALS CORP	*/
	if BoardID in(2371) then gvkey = '031193';	/*	DIGITAL ANGEL CORP-OLD2 matched on ticker May be 023964 */
	if BoardID in(8775) then gvkey = '060923';	/*	DAVE & BUSTER'S ENTMT INC	*/
	if BoardID in(13005) then gvkey = '005073';	/*	GENERAL MOTORS CO	*/
	if BoardID in(14142) then gvkey = '028018';	/*	GYMBOREE CORP	*/
	if BoardID in(15541) then gvkey = '005888';	/*	IGI Labs now TELIGENT INC	 */
	if BoardID in(17217) then gvkey = '011538';	/*	J. ALEXANDER'S HOLDINGS INC	*/
	if BoardID in(007163) then gvkey = '028018';	/*	MCGRAW-HILL FINANCIAL now S&P GLOBAL INC	*/
	if BoardID in(20064) then gvkey = '030950';	/*	MEDIA GENERAL INC	MATCHED ON cik */
	if BoardID in(20349) then gvkey = '007267';	/*	MERRILL LYNCH & CO INC	*/
/*	50*/
	if BoardID in(24460) then gvkey = '012785';	/*	PILGRIM'S PRIDE CORP	*/
	if BoardID in(27257) then gvkey = '111491';	/*	SCHOOL SPECIALTY INC	*/
	if BoardID in(33763) then gvkey = '011555';	/*	INTEGRYS HOLDING INC matched on CIK	*/
	if BoardID in(482963) then gvkey = '007450';	/*	MISSISSIPPI POWER CO	*/
	if BoardID in(16982) then gvkey = '001656';	/*	IQUNIVERSE INC 	*/
	if BoardID in(4919) then gvkey = '002410';	/*	BP PLC 	*/
	if BoardID in(46864) then gvkey = '009236';	/*	RHONE-POULENC RORER 	*/
	if BoardID in(1505) then gvkey = '015505';	/*	ALLIED IRISH BANKS 	*/
	if BoardID in(9074) then gvkey = '015576';	/*	DEUTSCHE BANK AG 	*/
	if BoardID in(27066) then gvkey = '103487';	/*	SAP SE 	*/
/*	60*/
	if BoardID in(23862) then gvkey = '125378';	/*	PARTNER COMMUNICATIONS CO 	*/
	if BoardID in(605022) then gvkey = '206059';	/*	NASPERS LTD 	*/
	if BoardID in(1043876) then gvkey = '242587';	/*	INDIANA RESOURCES LTD (IMX Resources Ltd prior to 06/2016)  	*/

/*	Confirmed missing link*/
	if BoardID in(26040) then Match_14 = 1;			/*	RENAISSANCE ENERGY (De-listed 08/2000) Canadian firm */
	if BoardID in(26098) then Match_14 = 1;			/*	RESOURCES FINANCE & INVESTMENT */
	if BoardID in(4860) then Match_14 = 1;			/*	BOSTON EDISON CO	*/
	if BoardID in(5541) then Match_14 = 1;			/*	CALIFORNIA COMMUNITY BANCSHARES INC	*/
	if BoardID in(3209) then Match_14 = 1;			/*	AVERY COMMUNICATIONS INC*/
	if BoardID in(1813507) then Match_14 = 1;		/*	STRATA MINERALS INC (JBZ Capital Inc prior to 11/2011) */
	if BoardID in(1322720) then Match_14 = 1;		/*	MAJESCOR RESOURCES INC */
	if BoardID in(1635910) then Match_14 = 1;		/*	VOLCANIC GOLD MINES INC (Volcanic Metals Corp prior to 01/2017) */
	if BoardID in(1054270) then Match_14 = 1;		/*	CARTIER IRON CORP (Northfield Metals Inc prior to 01/2013) */
/*	Sept 14*/
	if BoardID in(890046) then Match_14 = 1;	/*	CHINA LNG GROUP LIMITED (Artel Solutions Group Holdings Ltd prior to 06/2014)  	*/
	if BoardID in(1472330) then Match_14 = 1;	/*	CIPLA MEDPRO SOUTH AFRICA LTD (Enaleni Pharma Ltd prior to 11/2008) (De-listed 07/2013)  	*/
	if BoardID in(48921) then Match_14 = 1;	/*	HCL TECHNOLOGIES LTD  	*/
	if BoardID in(16023) then Match_14 = 1;	/*	ING BANK SLASKI SA  	*/
	if BoardID in(16966) then Match_14 = 1;	/*	IPSOS SA  	*/
	if BoardID in(1016765) then Match_14 = 1;	/*	JSC BANK OF GEORGIA  	*/
	if BoardID in(24523) then Match_14 = 1;	/*	PIRELLI & C SPA (De-listed 02/2016)  	*/
	if BoardID in(7590) then Match_14 = 1;	/*	SYGNITY SA (Computerland SA prior to 04/2007)  	*/
	if BoardID in(622) then Match_14 = 1;	/*	ACER INC	*/
	if BoardID in(2402) then Match_14 = 1;	/*	APRIL SA (April Group prior to 05/2011)	*/
	if BoardID in(2472) then gvkey = '066321';	/*	ROOMLINX INC (Arc Communication Inc prior to 08/2004)	*/
	if BoardID in(4223) then Match_14 = 1;	/*	SOCIETE BIC SA	*/
	if BoardID in(4511) then gvkey = '015530';	/*	BANK OF EAST ASIA LTD	*/
	if BoardID in(6376) then gvkey = '001953';	/*	CERPLEX GROUP INC	*/
	if BoardID in(7189) then gvkey = '029367';	/*	COASTCAST CORP (De-listed 09/2002)	*/
	if BoardID in(7873) then gvkey = '030442';	/*	CORAM HEALTHCARE CORP (De-listed 03/2000)	*/
	if BoardID in(8235) then gvkey = '030117';	/*	CRESCENT REAL ESTATES EQUITIES (De-listed 08/2007)	*/
	if BoardID in(9657) then gvkey = '162378';	/*	FAMILYMEDS GROUP INC (DrugMax Inc prior to 07/2006) (De-listed 01/2007)	*/
	if BoardID in(10001) then gvkey = '029803';	/*	EBT INTERNATIONAL INC	*/
	if BoardID in(10025) then gvkey = '004140';	/*	ECI TELECOM LTD (De-listed 10/2007)	*/
	if BoardID in(10125) then Match_14 = 1;	/*	EDIPRESSE SA	*/
	if BoardID in(10299) then gvkey = '013442';	/*	ELCOTEL	*/
	if BoardID in(10479) then Match_14 = 1;	/*	EMAP PLC (De-listed 03/2008)	*/
	if BoardID in(12310) then gvkey = '006226';	/*	FORT JAMES CORP (James River Corp of Virginia prior to 07/1997) (De-listed 11/2000)	*/
	if BoardID in(14321) then gvkey = '005038';	/*	HARCOURT GENERAL INC (De-listed 07/2001)	*/
	if BoardID in(15117) then gvkey = '015360';	/*	HOUSE2HOME INC	*/
	if BoardID in(15583) then gvkey = '124677';	/*	ILLUMINET HLDGS INC	*/
	if BoardID in(16928) then gvkey = '064420';	/*	IONA TECHNOLOGIES (De-listed 09/2008)	*/
	if BoardID in(17127) then Match_14 = 1;	/*	ITESOFT SA	*/
	if BoardID in(19434) then gvkey = '025367';	/*	MAGIC SOFTWARE ENTERPRISES LTD	*/
	if BoardID in(19737) then gvkey = '060993';	/*	MARTIN INDUSTRIES INC (De-listed 05/2001)	*/
	if BoardID in(20973) then Match_14 = 1;	/*	MOLICHEM MEDICINES	*/
	if BoardID in(21869) then gvkey = '123099';	/*	NETRADIO CORP (De-listed 10/2001)	*/
	if BoardID in(22016) then Match_14 = 1;	/*	NEW WAVE GROUP AB	*/
	if BoardID in(23894) then Match_14 = 1;	/*	PATHE	*/
	if BoardID in(25324) then gvkey = '027785';	/*	PROXIMA	*/
	if BoardID in(27526) then gvkey = '009589';	/*	SEITEL INC (De-listed 02/2007)	*/
	if BoardID in(28481) then gvkey = '106025';	/*	TELSON RESOURCES INC (Soho Resources Corp prior to 01/2013)	*/
	if BoardID in(29552) then gvkey = '028398';	/*	SUNGLASS HUT INTERNATIONAL INC (De-listed 04/2001)	*/
	if BoardID in(31312) then gvkey = '010724';	/*	TRIDEX CORP (De-listed 05/2000)	*/
	if BoardID in(31370) then gvkey = '137668';	/*	TRITON NETWORK SYSTEMS	*/
	if BoardID in(33429) then Match_14 = 1;	/*	WHATMAN PLC (De-listed 04/2008)	*/
	if BoardID in(34063) then gvkey = '007469';	/*	ZARLINK SEMICONDUCTOR INC (Mitel Corp prior to 05/2001) (De-listed 10/2011)	*/
	if BoardID in(536539) then gvkey = '065254';	/*	SIROCCO MINING INC (Atacama Minerals Corp prior to 01/2012) (De-listed 01/2014)	*/
	if BoardID in(550286) then Match_14 = 1;	/*	VELA TECHNOLOGIES PLC (Asia Digital Holdings PLC prior to 01/2013)	*/
	if BoardID in(605108) then gvkey = '165575';	/*	SYNENCO ENERGY INC (De-listed 08/2008)	*/
	if BoardID in(634145) then gvkey = '065744';	/*	LUNDIN GOLD INC (Fortress Minerals Corp prior to 12/2014)	*/
	if BoardID in(634385) then gvkey = '026767';	/*	LATTICE BIOLOGICS LTD (Blackstone Ventures Inc prior to 12/2015)	*/
	if BoardID in(745789) then gvkey = '064562';	/*	REDSTAR GOLD CORP (Redstar Resources Corp prior to 04/2002)	*/
	if BoardID in(747388) then gvkey = '031640';	/*	DIADEM RESOURCES LTD (De-listed 04/2015)	*/
	if BoardID in(805425) then gvkey = '031698';	/*	AGUILA AMERICAN GOLD LTD (Aguila American Resources Ltd prior to 05/2011)	*/
	if BoardID in(815463) then Match_14 = 1;	/*	CATHAY MERCHANT GROUP INC (De-listed 12/2007)	*/
	if BoardID in(872367) then Match_14 = 1;	/*	ALTITUDE GROUP PLC (Dowlis Corporate Solutions prior to 06/2008)	*/
	if BoardID in(917917) then gvkey = '108585';	/*	WEALTH MINERALS LTD	*/
	if BoardID in(924930) then gvkey = '162765';	/*	EESTOR CORP (ZENN Motor Co Inc prior to 04/2015)	*/
	if BoardID in(931849) then gvkey = '105562';	/*	BEAUFIELD RESOURCES INC	*/
	if BoardID in(950322) then gvkey = '065656';	/*	STEALTH VENTURES INC (Stealth Ventures Ltd prior to 08/2012) (De-listed 03/2016)	*/
	if BoardID in(956442) then gvkey = '141309';	/*	LICO ENERGY METALS INC (Wildcat Exploration Ltd prior to 10/2016)	*/
	if BoardID in(1026398) then Match_14 = 1;	/*	IDM INTERNATIONAL LTD (Industrial Minerals Corp Ltd prior to 12/2011) (De-listed 01/2016)	*/
	if BoardID in(1044968) then gvkey = '107616';	/*	NORONT RESOURCES LTD (White Wing Resources Inc prior to 07/1983)	*/
	if BoardID in(1060490) then gvkey = '186160';	/*	RYAN GOLD CORP (Valdez Gold Inc prior to 12/2010) (De-listed 08/2015)	*/
	if BoardID in(1067423) then gvkey = '151593';	/*	TRUE NORTH GEMS INC	*/
	if BoardID in(1073606) then Match_14 = 1;	/*	VALERO ENERGY CORP (De-listed 07/1997)	*/
	if BoardID in(1077982) then Match_14 = 1;	/*	TETRA BIO-PHARMA INC (Growpros Cannabis Ventures Inc prior to 09/2016)	*/
	if BoardID in(1192227) then gvkey = '119920';	/*	INTERNATIONAL SAMUEL EXPLORATION CORP (Consolidated TranDirect.com Technologies Inc prior to 06/2001)	*/
	if BoardID in(1208076) then gvkey = '178720';	/*	ARGENTUM SILVER CORP (Silex Ventures Ltd prior to 02/2011)	*/
	if BoardID in(1236259) then gvkey = '166218';	/*	NEW PACIFIC HOLDINGS CORP (New Pacific Metals Corp prior to 07/2016)	*/
	if BoardID in(1240770) then gvkey = '183268';	/*	POLAR STAR MINING CORP (De-listed 12/2014)	*/
	if BoardID in(1241128) then gvkey = '139242';	/*	XIANA MINING INC (Dorato Resources Inc prior to 10/2013)	*/
	if BoardID in(1241260) then gvkey = '106048';	/*	BRS RESOURCES LTD (Bonanza Resources Corp prior to 02/2011)	*/
	if BoardID in(1340318) then gvkey = '106356';	/*	OREX EXPLORATION INC (De-listed 05/2017)	*/
	if BoardID in(1478369) then gvkey = '177425';	/*	NORTH ARROW MINERALS INC	*/
	if BoardID in(1482020) then Match_14 = 1;	/*	UNIVERSAL BIOSENSORS INC	*/
	if BoardID in(1564127) then gvkey = '174377';	/*	AREHADA MINING LTD (Dragon Capital Corp prior to 07/2007) (De-listed 10/2014)	*/
	if BoardID in(1584916) then Match_14 = 1;	/*	CALTON INC (De-listed 04/2004)	*/
	if BoardID in(1638612) then gvkey = '025302';	/*	INTRUSION INC (Intrusion.com Inc prior to 03/2001) (De-listed 10/2006)	*/
	if BoardID in(1656896) then gvkey = '183882';	/*	HEATHERDALE RESOURCES LTD	*/
	if BoardID in(1694070) then gvkey = '186664';	/*	CASTLE PEAK MINING LTD (Formerly known as Critical Capital Corporation)	*/
	if BoardID in(1710274) then gvkey = '183226';	/*	EUROTIN INC	*/
	if BoardID in(1718240) then gvkey = '177798';	/*	NEVADO RESOURCES CORP	*/
	if BoardID in(1718504) then gvkey = '025399';	/*	HAMPSHIRE GROUP LTD (De-listed 01/2007)	*/
	if BoardID in(1750334) then Match_14 = 1;	/*	CERTIVE SOLUTIONS INC (VisualVault Corp prior to 10/2013)	*/
	if BoardID in(1820640) then Match_14 = 1;	/*	NEW DESTINY MINING CORP	*/
	if BoardID in(1823399) then gvkey = '187410';	/*	ANNIDIS CORP (Aumento Capital Corp prior to 06/2011)	*/
	if BoardID in(1826034) then gvkey = '187794';	/*	COMSTOCK METALS LTD (Tectonic Capital Corp prior to 04/2009)	*/
	if BoardID in(1873273) then gvkey = '027026';	/*	VAXIL BIO LTD (Emerge Resources Corp prior to 03/2016)	*/
	if BoardID in(1879825) then Match_14 = 1;	/*	VOLTAIC MINERALS CORP (Prima Diamond Corp prior to 04/2016)	*/
	if BoardID in(1917129) then gvkey = '184172';	/*	DECLAN RESOURCES INC (Kokanee Minerals Inc prior to 04/2012)	*/

	if BoardID in(1096090) then gvkey = '116591';	/*	ALTURAS MINERALS CORP  */
	if BoardID in(1056054) then Match_14 = 1;	/*	ARMOR DESIGNS INC (De-listed 01/2015)  */
	if BoardID in(33410) then gvkey = '011450';	/*	WESTWOOD ONE INC (De-listed 11/2008)  */

	if not missing(gvkey) then Match_13 = 1;
	if ((Match_13 ne 1) and (Match_14 ne 1)) then delete;
	keep BoardID gvkey Match_13 Match_14;
run;

/*
proc sort data=MMatch_00 out=MMatch_01 nodupkey;
	by BoardID;
run;
proc sort data=MMatch_01;
	by CompanyName;
run;
*/


/*
data boardex.MMatch;
	set MMatch_01;
run;
*/

