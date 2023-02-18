*-----------------------------------------------------------------------------
	SUBROUTINE AMR.BA.SMS.SUBS.PROCESS
*-----------------------------------------------------------------------------
* VERSION             : 1.0
* DATE CREATED        : 24/03/2020
* CREATED BY          : Swetha S
* DESCRIPTION         : Before Auth routine for Alerts Subscription Process
* ATTACHED TO         : VERSION>AMR.SMS.SUBS,AMR.INPUT
* ATTACHED AS         : Before Auth Routine
* IN/OUT ARGUMENTS    : N/A
*-----------------------------------------------------------------------------
* VERSION             : 2.0
* DATE MODIFIED       : 30/08/2021
* MODIFIED BY         : RASY
* MODIFICATION DETAIL : CHG0033780 - issue not charge SMS & Email monthly fee
*                       INC0022425 - issue cannot AUTH SMS sub. when DE.PRODUCT
*                       MOBILE.1 already exist
*-----------------------------------------------------------------------------
    $INSERT I_COMMON
    $INSERT I_EQUATE
	$INSERT I_GTS.COMMON
	$INSERT I_F.OFS.SOURCE
    $INSERT I_F.ACCOUNT
    $INSERT I_F.CUSTOMER
	$INSERT I_F.DE.PRODUCT
    $INSERT I_F.FUNDS.TRANSFER
	$INSERT I_F.AMR.SMS.SUBS
    $INSERT I_F.EB.ALERT.REQUEST
    $INSERT I_F.AMR.H.INTF.PARAM
 
    GOSUB PROCESS
    GOSUB CHECK.CUSTOMER
    
    IF Y.PRODUCT.FLAG EQ 1 AND Y.SMS.SUBS.IND EQ 'YES' THEN
        AMR.TRANSACTION.ID2 = 'KH0010001.A-':Y.ACCOUNT:'.8230.AC'
		GOSUB INIT.CARR.ADD
        GOSUB CREATE.DE.PRODUCT ;* CR 

        AMR.TRANSACTION.ID2 = 'KH0010001.A-':Y.ACCOUNT:'.8240.AC'
		GOSUB INIT.CARR.ADD
        GOSUB CREATE.DE.PRODUCT ;* DR
    END
	RETURN

*-----------------------------------------------------------------------------
PROCESS:
*-----------------------------------------------------------------------------
    Y.ACCOUNT = ID.NEW
	Y.TODAY = TODAY

	Y.SMS.SUBS.IND = R.NEW(AMR.SMS.SMS.SUBS.INDICATOR)
	
	Y.NTF.TYPES = R.NEW(AMR.SMS.SMS.NOTIFICATION.TYPE)
	Y.NTF.TYPE.CNT = DCOUNT(Y.NTF.TYPES,VM)

    Y.EVENT.TYPES = R.NEW(AMR.SMS.EVENT.TYPES)
    Y.EVENT.TYPE.CNT = DCOUNT(Y.EVENT.TYPES,VM)
	
	FN.EB.ALERT.REQUEST = 'F.EB.ALERT.REQUEST'
    F.EB.ALERT.REQUEST = ''
    CALL OPF(FN.EB.ALERT.REQUEST,F.EB.ALERT.REQUEST)

    FN.ACCOUNT = 'F.ACCOUNT'
    F.ACCOUNT = ''
    CALL OPF(FN.ACCOUNT,F.ACCOUNT)
    
    FN.CUSTOMER = 'F.CUSTOMER'
    F.CUSTOMER = ''
    CALL OPF(FN.CUSTOMER,F.CUSTOMER)
    
    FN.DE.PRODUCT = 'F.DE.PRODUCT'
    F.DE.PRODUCT = ''
    CALL OPF(FN.DE.PRODUCT,F.DE.PRODUCT)
    
    FN.DE.PRODUCT.HIS = 'F.DE.PRODUCT$HIS'
    F.DE.PRODUCT.HIS = ''
    CALL OPF(FN.DE.PRODUCT.HIS,F.DE.PRODUCT.HIS)

    FN.AMR.INTF.PARAM = 'F.AMR.H.INTF.PARAM'
    Y.AMR.INTF.PARAM = 'SMSCHGPL'
    
    CALL CACHE.READ(FN.AMR.INTF.PARAM,Y.AMR.INTF.PARAM,R.AMR.INTF.PARAM,E.AMR.INTF.PARAM)
    Y.PL.ACC = R.AMR.INTF.PARAM<AIP.VALUE.FROM>

    MATBUILD Y.BEFORE.IMG.REC FROM R.OLD
    MATBUILD Y.AFTER.IMG.REC FROM R.NEW
    Y.SMS.SUBS.IND.OLD = Y.BEFORE.IMG.REC<AMR.SMS.SMS.SUBS.INDICATOR>
    Y.SMS.SUBS.IND.NEW = Y.AFTER.IMG.REC<AMR.SMS.SMS.SUBS.INDICATOR>
    
    IF Y.SMS.SUBS.IND.OLD NE Y.SMS.SUBS.IND.NEW THEN
        GOSUB PROCESS.SUBSCRIBE
        GOSUB PROCESS.TRIGGER.ALERT
    END
	RETURN

*-----------------------------------------------------------------------------
PROCESS.SUBSCRIBE:
*-----------------------------------------------------------------------------
    CALL F.READ(FN.ACCOUNT,Y.ACCOUNT,R.ACCOUNT,F.ACCOUNT,E.ACCOUNT)
    Y.REQ.IDS = R.ACCOUNT<AC.REQUEST.ID>

    IF Y.SMS.SUBS.IND EQ 'NO' THEN
        GOSUB PROCESS.NO
    END 
	ELSE
        GOSUB PROCESS.YES
		
		IF Y.SMS.SUBS.IND.OLD NE 'YES' THEN
			GOSUB COLLECT.SUBS.FEE
		END
    END
	RETURN

*-----------------------------------------------------------------------------
PROCESS.YES:
*-----------------------------------------------------------------------------
    Y.SUBS = 'YES'

	IF Y.REQ.IDS EQ '' THEN
		Y.INT = 1
		LOOP
		WHILE Y.INT LE Y.EVENT.TYPE.CNT
			Y.EVENT = FIELD(Y.EVENT.TYPES,VM,Y.INT)
			Y.ALERT.ID = Y.REQ.IDS<1,Y.INT>
			GOSUB PROCESS.UPDATE.ALERT

			Y.INT++
		REPEAT
	END

    Y.SUBS.YES.IND = R.NEW(AMR.SMS.YES.INDICATOR) + 1
    Y.SUBS.NO.IND = R.NEW(AMR.SMS.NO.INDICATOR)
	RETURN

*-----------------------------------------------------------------------------
PROCESS.NO:
*-----------------------------------------------------------------------------
    Y.AMR.PRODUCT.ID1 = 'KH0010001.A-':Y.ACCOUNT:'.8230.AC'
    Y.AMR.PRODUCT.ID1.HIS1 = 'KH0010001.A-':Y.ACCOUNT:'.8230.AC;1'
    Y.AMR.PRODUCT.ID1.HIS2 = 'KH0010001.A-':Y.ACCOUNT:'.8230.AC;2'
    
    Y.AMR.PRODUCT.ID2 = 'KH0010001.A-':Y.ACCOUNT:'.8240.AC'
    Y.AMR.PRODUCT.ID2.HIS1 = 'KH0010001.A-':Y.ACCOUNT:'.8240.AC;1'
    Y.AMR.PRODUCT.ID2.HIS2 = 'KH0010001.A-':Y.ACCOUNT:'.8240.AC;2'
    
    CALL F.READ(FN.DE.PRODUCT,Y.AMR.PRODUCT.ID1,R.DE.PRODUCT.ID1,F.DE.PRODUCT,E.DE.PRODUCT)
    CALL F.READ(FN.DE.PRODUCT,Y.AMR.PRODUCT.ID2,R.DE.PRODUCT.ID2,F.DE.PRODUCT,E.DE.PRODUCT)

    CALL F.READ(FN.DE.PRODUCT.HIS,Y.AMR.PRODUCT.ID1.HIS1,R.DE.PRODUCT.ID1.HIS1,F.DE.PRODUCT.HIS,E.DE.PRODUCT)
    CALL F.READ(FN.DE.PRODUCT.HIS,Y.AMR.PRODUCT.ID2.HIS1,R.DE.PRODUCT.ID2.HIS1,F.DE.PRODUCT.HIS,E.DE.PRODUCT)

    CALL F.READ(FN.DE.PRODUCT.HIS,Y.AMR.PRODUCT.ID1.HIS2,R.DE.PRODUCT.ID1.HIS2,F.DE.PRODUCT.HIS,E.DE.PRODUCT)
    CALL F.READ(FN.DE.PRODUCT.HIS,Y.AMR.PRODUCT.ID2.HIS2,R.DE.PRODUCT.ID2.HIS2,F.DE.PRODUCT.HIS,E.DE.PRODUCT)
    
    Y.CARRIER.CR = R.DE.PRODUCT.ID1<DE.PRD.CARR.ADD.NO>
    Y.CARRIER.CR.CNT = DCOUNT(Y.CARRIER.CR,VM)

	Y.CARRIER.DR = R.DE.PRODUCT.ID2<DE.PRD.CARR.ADD.NO>
    Y.CARRIER.DR.CNT = DCOUNT(Y.CARRIER.DR,VM)

	AMR.APP.NAME = 'DE.PRODUCT'
	AMR.OFSVERSION = 'DE.PRODUCT,AMR.INPUT'
    AMR.OFSFUNCT = 'I'
    AMR.PROCESS = 'PROCESS'
    AMR.GTSMODE = ''
    AMR.NO.OF.AUTH = '0'

	Y.MOBILE = 'MOBILE.1'
	
	LOCATE Y.MOBILE IN R.DE.PRODUCT.ID1<DE.PRD.CARR.ADD.NO,1> SETTING POS1 THEN
		AMR.PRDREC = ''
		AMR.PRDREC<DE.PRD.CARR.ADD.NO,1> = Y.MOBILE
        AMR.PRDREC<DE.PRD.TRANSLATION,1> = "GB"
		
		IF Y.CARRIER.CR.CNT GE 1 THEN
			GOSUB DELETE.DE.PRODUCT.CR
			
			AMR.RECORD = ''
			AMR.OFSRECORD = ''
			AMR.RECORD = AMR.PRDREC

            CALL OFS.BUILD.RECORD(AMR.APP.NAME,AMR.OFSFUNCT,AMR.PROCESS,AMR.OFSVERSION,AMR.GTSMODE,AMR.NO.OF.AUTH,Y.AMR.PRODUCT.ID1,AMR.RECORD,AMR.OFSRECORD)
       
            AMR.insertOrAdd = ''
            AMR.ERROR = ''
            CALL ofs.addLocalRequest(AMR.OFSRECORD,AMR.insertOrAdd,AMR.ERROR)
		END
	END
	ELSE
		GOSUB DELETE.DE.PRODUCT.CR
	END

	LOCATE Y.MOBILE IN R.DE.PRODUCT.ID2<DE.PRD.CARR.ADD.NO,1> SETTING POS2 THEN
		AMR.PRDREC = ''
		AMR.PRDREC<DE.PRD.CARR.ADD.NO,1> = Y.MOBILE
        AMR.PRDREC<DE.PRD.TRANSLATION,1> = "GB"
		
		IF Y.CARRIER.DR.CNT GE 1 THEN
			GOSUB DELETE.DE.PRODUCT.DR
			
			AMR.RECORD = ''
			AMR.OFSRECORD = ''
			AMR.RECORD = AMR.PRDREC
			
			CALL OFS.BUILD.RECORD(AMR.APP.NAME,AMR.OFSFUNCT,AMR.PROCESS,AMR.OFSVERSION,AMR.GTSMODE,AMR.NO.OF.AUTH,Y.AMR.PRODUCT.ID2,AMR.RECORD,AMR.OFSRECORD)
            
            AMR.insertOrAdd = ''
            AMR.ERROR = ''
            CALL ofs.addLocalRequest(AMR.OFSRECORD,AMR.insertOrAdd,AMR.ERROR)
		END
	END
	ELSE
		GOSUB DELETE.DE.PRODUCT.DR
	END
	RETURN

*-----------------------------------------------------------------------------
DELETE.DE.PRODUCT.CR:
*-----------------------------------------------------------------------------
* delete all DE.PRODUCT records for CR side
    CALL F.DELETE(FN.DE.PRODUCT,Y.AMR.PRODUCT.ID1)
	CALL F.DELETE(FN.DE.PRODUCT.HIS,Y.AMR.PRODUCT.ID1.HIS1)
	CALL F.DELETE(FN.DE.PRODUCT.HIS,Y.AMR.PRODUCT.ID1.HIS2)
	
	Y.SUBS.NO.IND = R.NEW(AMR.SMS.NO.INDICATOR) + 1
	Y.SUBS.YES.IND = R.NEW(AMR.SMS.YES.INDICATOR)
	RETURN

*-----------------------------------------------------------------------------	
DELETE.DE.PRODUCT.DR:
*-----------------------------------------------------------------------------
* delete all DE.PRODUCT records for DR side
    CALL F.DELETE(FN.DE.PRODUCT,Y.AMR.PRODUCT.ID2)
    CALL F.DELETE(FN.DE.PRODUCT.HIS,Y.AMR.PRODUCT.ID2.HIS1)
    CALL F.DELETE(FN.DE.PRODUCT.HIS,Y.AMR.PRODUCT.ID2.HIS2)
	
	Y.SUBS.NO.IND = R.NEW(AMR.SMS.NO.INDICATOR) + 1
	Y.SUBS.YES.IND = R.NEW(AMR.SMS.YES.INDICATOR)
	RETURN

*-----------------------------------------------------------------------------
PROCESS.UPDATE.ALERT:
*-----------------------------------------------------------------------------
	Y.APP = 'EB.ALERT.REQUEST'
    Y.VERSION = 'EB.ALERT.REQUEST,TM.AMR'
	Y.FUNCT = 'I'
    Y.PROCESS = 'PROCESS'
    Y.GTS = '1'
    Y.AUTH = '0'

	REC.UPDATE = ''
	AMR.OFSRECORD = ''
    
    CALL F.READ(FN.EB.ALERT.REQUEST,Y.ALERT.ID,R.EB.ALERT.REQUEST,F.EB.ALERT.REQUEST,E.EB.ALERT.REQUEST)

    IF R.EB.ALERT.REQUEST EQ '' THEN
        REC.UPDATE<EB.AR.EVENT> = Y.EVENT
        REC.UPDATE<EB.AR.CONTRACT.REF> = Y.ACCOUNT
    END

    REC.UPDATE<EB.AR.SUBSCRIBE> = Y.SUBS
    
    CALL OFS.BUILD.RECORD(Y.APP,Y.FUNCT,Y.PROCESS,Y.VERSION,Y.GTS,Y.AUTH,Y.ALERT.ID,REC.UPDATE,AMR.OFSRECORD)

    AMR.insertOrAdd = ''
    AMR.ERROR = ''
    CALL ofs.addLocalRequest(AMR.OFSRECORD,AMR.insertOrAdd,AMR.ERROR)
	RETURN

*-----------------------------------------------------------------------------
PROCESS.TRIGGER.ALERT:
*-----------------------------------------------------------------------------
    AMR.APP.NAME = 'AMR.SMS.SUBS'
	AMR.OFSVERSION = 'AMR.SMS.SUBS,TM.AMR'
    AMR.OFSFUNCT = 'I'
    AMR.PROCESS = 'PROCESS'
    AMR.GTSMODE = ''
    AMR.NO.OF.AUTH = '0'
    AMR.TRANSACTION.ID1 = Y.ACCOUNT

    AMR.RECORD = ''
    AMR.OFSRECORD = ''
 
    AMR.RECORD<AMR.SMS.YES.INDICATOR> = Y.SUBS.YES.IND
    AMR.RECORD<AMR.SMS.NO.INDICATOR> = Y.SUBS.NO.IND
    
    CALL OFS.BUILD.RECORD(AMR.APP.NAME,AMR.OFSFUNCT,AMR.PROCESS,AMR.OFSVERSION,AMR.GTSMODE,AMR.NO.OF.AUTH,AMR.TRANSACTION.ID1,AMR.RECORD,AMR.OFSRECORD)
        
    AMR.insertOrAdd = ''
    AMR.ERROR = ''
    CALL ofs.addLocalRequest(AMR.OFSRECORD,AMR.insertOrAdd,AMR.ERROR)
	RETURN

*-----------------------------------------------------------------------------
CHECK.CUSTOMER:
*-----------------------------------------------------------------------------
    Y.PRODUCT.FLAG = 0
	Y.NTF.IND = TRIM(Y.NTF.TYPES,VM,'A')
	
	CALL F.READ(FN.ACCOUNT,Y.ACCOUNT,R.ACCOUNT,F.ACCOUNT,E.ACCOUNT)
    Y.CUSTOMER = R.ACCOUNT<AC.CUSTOMER>

    CALL F.READ(FN.CUSTOMER,Y.CUSTOMER,R.CUSTOMER,F.CUSTOMER,E.CUSTOMER)
	Y.IS.SMS = R.CUSTOMER<EB.CUS.SMS.1>
	Y.IS.EML = R.CUSTOMER<EB.CUS.EMAIL.1>
	
	IF Y.NTF.IND EQ 'SMSEMAIL' OR Y.NTF.IND EQ 'EMAILSMS' OR Y.NTF.IND EQ 'SMS' OR Y.NTF.IND EQ 'EMAIL' THEN
		Y.PRODUCT.FLAG = 1
	END
	RETURN

*-----------------------------------------------------------------------------
INIT.CARR.ADD:
*-----------------------------------------------------------------------------
* this sub is use to either initial new or generate extend Carrier Address
	CALL F.READ(FN.DE.PRODUCT,AMR.TRANSACTION.ID2,R.DE.PRODUCT,F.DE.PRODUCT,E.DE.PRODUCT)
	Y.CARRIER = R.DE.PRODUCT<DE.PRD.CARR.ADD.NO>
    Y.CARRIER.CNT = DCOUNT(Y.CARRIER,VM)
	
	IF Y.CARRIER.CNT GE 1 THEN
		Y.MV = Y.CARRIER.CNT + 1 ;* increase MV to the correct value
	END
	ELSE
		Y.MV = 1
	END

    AMR.PRDREC = ''

    IF Y.IS.SMS THEN
        AMR.PRDREC<DE.PRD.CARR.ADD.NO,Y.MV> = "SMS.1"
        AMR.PRDREC<DE.PRD.TRANSLATION,Y.MV> = "GB"
		Y.MV++
    END
    IF Y.IS.EML THEN
        AMR.PRDREC<DE.PRD.CARR.ADD.NO,Y.MV> = "EMAIL.1"
        AMR.PRDREC<DE.PRD.TRANSLATION,Y.MV> = "GB"
    END
	RETURN

*-----------------------------------------------------------------------------
CREATE.DE.PRODUCT:
*-----------------------------------------------------------------------------
    AMR.APP.NAME = 'DE.PRODUCT'
	AMR.OFSVERSION = 'DE.PRODUCT,AMR.INPUT'
    AMR.OFSFUNCT = 'I'
    AMR.PROCESS = 'PROCESS'
    AMR.GTSMODE = ''
    AMR.NO.OF.AUTH = '0'
    
    BEGIN CASE
        CASE R.DE.PRODUCT EQ '' ;* create new DE.PRODUCT if empty
			AMR.RECORD = ''
            AMR.OFSRECORD = ''

			AMR.RECORD = AMR.PRDREC

            CALL OFS.BUILD.RECORD(AMR.APP.NAME,AMR.OFSFUNCT,AMR.PROCESS,AMR.OFSVERSION,AMR.GTSMODE,AMR.NO.OF.AUTH,AMR.TRANSACTION.ID2,AMR.RECORD,AMR.OFSRECORD)

			AMR.insertOrAdd = ''
            AMR.ERROR = ''
            CALL ofs.addLocalRequest(AMR.OFSRECORD,AMR.insertOrAdd,AMR.ERROR)
			IF AMR.ERROR NE "" THEN ;* to make sure that it raise error when it cannot create DE.PRODUCT
				ETEXT = AMR.ERROR
				CALL STORE.END.ERROR
			END

        CASE R.DE.PRODUCT AND Y.CARRIER.CNT EQ 1 AND Y.CARRIER EQ 'MOBILE.1' ;* extend DE.PRODUCT if value exist-MOBILE.1
			AMR.RECORD = ''
            AMR.OFSRECORD = ''

			AMR.RECORD = AMR.PRDREC

            CALL OFS.BUILD.RECORD(AMR.APP.NAME,AMR.OFSFUNCT,AMR.PROCESS,AMR.OFSVERSION,AMR.GTSMODE,AMR.NO.OF.AUTH,AMR.TRANSACTION.ID2,AMR.RECORD,AMR.OFSRECORD)

			AMR.insertOrAdd = ''
            AMR.ERROR = ''
            CALL ofs.addLocalRequest(AMR.OFSRECORD,AMR.insertOrAdd,AMR.ERROR)
			IF AMR.ERROR NE "" THEN ;* to make sure that it raise error when it cannot create DE.PRODUCT
				ETEXT = AMR.ERROR
				CALL STORE.END.ERROR
			END
    END CASE
	RETURN

*-----------------------------------------------------------------------------
COLLECT.SUBS.FEE:
*-----------------------------------------------------------------------------
	Y.FEE.AMT = R.NEW(AMR.SMS.SUBSCRIPTION.FEE)
	Y.CCY = R.NEW(AMR.SMS.CURRENCY)
    
    IF Y.FEE.AMT GT 0 THEN
        AMR.APP.NAME = 'FUNDS.TRANSFER'
		AMR.OFSVERSION = 'FUNDS.TRANSFER,AMR.OFS'
        AMR.OFSFUNCT = 'I'
        AMR.PROCESS = 'PROCESS'
        AMR.GTSMODE = ''
        AMR.NO.OF.AUTH = '0'
        AMR.TRANSACTION.ID = ''

		AMR.RECORD = ''
        AMR.OFSRECORD = ''

        AMR.RECORD<FT.TRANSACTION.TYPE> = 'ACSF'
        AMR.RECORD<FT.DEBIT.ACCT.NO> = Y.ACCOUNT
        AMR.RECORD<FT.CREDIT.ACCT.NO> = Y.PL.ACC
        AMR.RECORD<FT.CREDIT.CURRENCY> = Y.CCY
        AMR.RECORD<FT.CREDIT.AMOUNT> = Y.FEE.AMT
    
        CALL OFS.BUILD.RECORD(AMR.APP.NAME,AMR.OFSFUNCT,AMR.PROCESS,AMR.OFSVERSION,AMR.GTSMODE,AMR.NO.OF.AUTH,AMR.TRANSACTION.ID,AMR.RECORD,AMR.OFSRECORD)

		AMR.insertOrAdd = ''
		AMR.ERROR = ''
        CALL ofs.addLocalRequest(AMR.OFSRECORD,AMR.insertOrAdd,AMR.ERROR)
		IF AMR.ERROR EQ '' THEN
			FOR Y.MV = 1 TO Y.NTF.TYPE.CNT
				Y.FREQ.DATE = R.NEW(AMR.SMS.FREQ.DATE)<1,Y.MV>
				GOSUB SET.FREQ.DATE ;* to update FREQ.DATE to next schedule after 1st subscription fee paid
			NEXT Y.MV
		END
    END
	RETURN

*-----------------------------------------------------------------------------
SET.FREQ.DATE:
*-----------------------------------------------------------------------------
    IF Y.FREQ.DATE THEN
		Y.NEXT.DATE = Y.FREQ.DATE
		Y.SIGN = '+'
		Y.DISPLACEMENT = '1M'
		CALL CALENDAR.DAY(Y.NEXT.DATE,Y.SIGN,Y.DISPLACEMENT)
		Y.NEXT.DATE = Y.DISPLACEMENT

        R.NEW(AMR.SMS.FREQ.DATE)<1,Y.MV> = Y.NEXT.DATE
    END
	RETURN
END
