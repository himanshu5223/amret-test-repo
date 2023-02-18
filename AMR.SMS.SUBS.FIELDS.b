*-----------------------------------------------------------------------------
* <Rating>-11</Rating>
*-----------------------------------------------------------------------------
SUBROUTINE AMR.SMS.SUBS.FIELDS
*-----------------------------------------------------------------------------
*<doc>
* Template for field definitions routine YOURAPPLICATION.FIELDS
*
* @author tcoleman@temenos.com
* @stereotype fields template
* @uses Table
* @public Table Creation
* @package infra.eb
* </doc>
*-----------------------------------------------------------------------------
* Modification History :
*
* 19/10/07 - EN_10003543
*            New Template changes
*
* 14/11/07 - BG_100015736
*            Exclude routines that are not released
*-----------------------------------------------------------------------------
*** <region name= Header>
*** <desc>Inserts and control logic</desc>
    $INSERT I_COMMON
    $INSERT I_EQUATE
    $INSERT I_DataTypes
*** </region>
*-----------------------------------------------------------------------------
*    CALL Table.defineId("AMR.SMS.SUBS", T24_String)    ;* Define Table id
*-----------------------------------------------------------------------------
*    CALL Table.addField(fieldName, fieldType, args, neighbour) ;* Add a new fields
*    CALL Field.setCheckFile(fileName)        ;* Use DEFAULT.ENRICH from SS or just field 1
	
    ID.F = "ACCOUNT.ID"
    ID.N = "25"
    ID.T = "A"
    ID.CHECKFILE = "ACCOUNT"

    CALL Table.addOptionsField('SMS.SUBS.INDICATOR',"YES_NO",'','')
    CALL Table.addOptionsField('VIP.CLIENT',"YES_NO",'','')
    CALL Table.addFieldDefinition('MONTHLY.SMS.FEE.PER.UNIT',35,'AMT','')
    CALL Table.addFieldDefinition('MONTHLY.EMAIL.FEE.PER.UNIT',35,'AMT','')
    CALL Table.addOptionsField('XX<SMS.NOTIFICATION.TYPE',"SMS_EMAIL",'','')
    CALL Table.addOptionsField('XX-CHARGE',"YES_NO",'','')
    CALL Table.addFieldDefinition('XX-PROMOTION.PERIOD',35,'A','')
    CALL Table.addFieldDefinition('XX-PROMOTION.START.DATE',10,'D','')
    CALL Table.addFieldDefinition('XX-PROMOTION.END.DATE',10,'D','')
    CALL Table.addFieldDefinition('XX>FREQ.DATE',10,'D','')
    CALL Table.addFieldDefinition('XX.EVENT.TYPES',35,'ANY','')
    CALL Field.setCheckFile("TEC.ITEMS")
    CALL Table.addFieldDefinition('YES.INDICATOR',10,'ANY','')
    CALL Table.addFieldDefinition('NO.INDICATOR',10,'ANY','')
    CALL Table.addFieldDefinition('CUSTOMER',10,'','')
    CALL Field.setCheckFile("CUSTOMER")
    CALL Table.addFieldDefinition('CURRENCY',10,'CCY','')
    CALL Field.setCheckFile("CURRENCY")
    CALL Table.addLocalReferenceField("")
    CALL Table.addFieldDefinition('CUS.COMPANY',10,'A','')
    CALL Field.setCheckFile("COMPANY")
    CALL Table.addFieldDefinition('SUBSCRIPTION.FEE',35,'AMT','')
    CALL Table.addReservedField("Reserved3")
    CALL Table.addReservedField("Reserved2")
    CALL Table.addReservedField("Reserved1")
    CALL Table.addOverrideField
*    CALL Table.addFieldWithEbLookup(fieldName,virtualTableName,neighbour) ;* Specify Lookup values
*    CALL Field.setDefault(defaultValue) ;* Assign default value
*-----------------------------------------------------------------------------
    CALL Table.setAuditPosition         ;* Populate audit information
*-----------------------------------------------------------------------------
RETURN
*-----------------------------------------------------------------------------
END



