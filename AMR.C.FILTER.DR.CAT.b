*------------------------------------------------------------------------------
SUBROUTINE AMR.C.FILTER.DR.CAT(DATA.IN, ARG2, ARG3, DATA.OUT, ARG5)
*------------------------------------------------------------------------------
* VERSION             : 1.0
* DATE CREATED        :
* CREATED BY          :
* DESCRIPTION         : This routine is to filter category for DR.
* ATTACHED TO         : DE.FORMAT.XML>8240.1.2.GB,8240.1.3.GB
* ATTACHED AS         : CONVERSION ROUTINE
* IN/OUT ARGUMENTS    : DATA.IN,DATA.OUT
*-------------------------------------------------------------------------------
* DEVELOPER NAME      : SOK KHINHHAK
* DEVELOPMENT DATE    : 10 NOV 2021
* REFERENCE           : INC0023907 SMS/Email doesn't display name when FT is cross branch
*-------------------------------------------------------------------------------
* DEVELOPER NAME      : Seit Lyheang
* DEVELOPMENT DATE    : 07 Feb 2022
* REFERENCE           : INC0023907 DCD-SMS and Email content not correct formate in production
*-------------------------------------------------------------------------------
	
    $INSERT I_COMMON
    $INSERT I_EQUATE
    $INSERT I_F.FUNDS.TRANSFER
    $INSERT I_F.ACCOUNT
    $INSERT I_F.AMR.H.INTF.PARAM
    $INSERT I_F.CUSTOMER

    GOSUB PROCESS.OPENFILES
    GOSUB PROCESS.FILTER
RETURN

*---------------------------
PROCESS.OPENFILES:
*---------------------------

    FN.FUNDSTFR = 'F.FUNDS.TRANSFER'
    F.FUNDSTFR = ''
    CALL OPF(FN.FUNDSTFR,F.FUNDSTFR)
	
	FN.FT.HIS = 'F.FUNDS.TRANSFER$HIS' ;*INC0023907
    F.FT.HIS = ''
    CALL OPF(FN.FT.HIS,F.FT.HIS)
  
    FN.ACCOUNT = 'F.ACCOUNT'
    F.ACCOUNT = ''
    CALL OPF(FN.ACCOUNT,F.ACCOUNT)
    
    FN.PARAM = 'F.AMR.H.INTF.PARAM'
    F.PARAM = ''
    CALL OPF(FN.PARAM,F.PARAM)

    FN.CUSTOMER = 'F.CUSTOMER'
    F.CUSTOMER = ''
    CALL OPF(FN.CUSTOMER,F.CUSTOMER)

RETURN

*---------------------------
PROCESS.FILTER:
*---------------------------
	  
    Y.TRANS.REF = FIELD(DATA.IN,'\',1) ;*INC0023907
    
    Y.APPLICATION = 'FUNDS.TRANSFER'
    Y.FIELD = 'L.AMR.RECV.NAME'
    Y.POS = ''
    CALL MULTI.GET.LOC.REF(Y.APPLICATION,Y.FIELD,Y.POS)
    
    CALL F.READ(FN.FUNDSTFR,Y.TRANS.REF,R.FUNDSTFR,F.FUNDSTFR,E.FUNDSTFR)
	IF R.FUNDSTFR EQ '' THEN CALL F.READ(FN.FT.HIS,Y.TRANS.REF:';1',R.FUNDSTFR,F.FT.HIS,E.FUNDSTFR) ;*INC0023907
    Y.DEBIT.ACCOUNT = R.FUNDSTFR<FT.DEBIT.ACCT.NO>
    Y.RECV.NAME = R.FUNDSTFR<FT.LOCAL.REF,Y.POS>
    
    IF Y.RECV.NAME ELSE
        Y.RECV.CUS = R.FUNDSTFR<FT.CREDIT.CUSTOMER>
        CALL F.READ(FN.CUSTOMER,Y.RECV.CUS,R.RECV.CUS,F.CUSTOMER,E.RECV.CUS)
		*Start INC0023907
        Y.NAME.1 = R.RECV.CUS<EB.CUS.NAME.1,1>
		Y.SHORT.NAME = R.RECV.CUS<EB.CUS.SHORT.NAME,1>
		Y.RECV.NAME = Y.SHORT.NAME:" ":Y.NAME.1
		*End INC0023907
    END
    
    CALL F.READ(FN.ACCOUNT,Y.DEBIT.ACCOUNT,R.ACCOUNT,F.ACCOUNT,E.ACCOUNT)
    Y.CATEGORY = R.ACCOUNT<AC.CATEGORY>
    
    Y.PARAM = 'SMSCAT'
    CALL F.READ(FN.PARAM,Y.PARAM,R.PARAM,F.PARAM,E.PARAM)
    Y.FROM.CAT = R.PARAM<AIP.VALUE.FROM>
    Y.TO.CAT = R.PARAM<AIP.VALUE.TO>
    
    IF Y.CATEGORY GE Y.FROM.CAT AND Y.CATEGORY LE Y.TO.CAT THEN
        Y.DATA.OUT = Y.RECV.NAME
    END ELSE
        Y.DATA.OUT = ''
    END
    
    DATA.OUT = Y.DATA.OUT
    
RETURN
    
END