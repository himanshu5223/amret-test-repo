*-----------------------------------------------------------------------------
* <Rating>-64</Rating>
*-----------------------------------------------------------------------------
$PACKAGE DE.Outward
SUBROUTINE AMR.EMAIL.JAVA.INTERFACE(misn,deliveryPackage,genericData,errorResponse)
*-----------------------------------------------------------------------------
*** <region name= Description>
*** <desc>Description </desc>
* This subroutine acts as an intermediator between T24 Delivery module and Java
* Carrier Interface for SMS. This initiates the call to Java Carrier Interface
* with the delivery message supplied by the Delivery module and returns the
* response back in case if there is any failure.
* Arguments:
* ----------
* misn            - Not used [Incoming]
* deliveryPackage - Package of delivery messages from delivery module.[Incoming]
* genericData     - Not used [Incoming]
* errorResponse   - Error message from Java interface if the delivery is failed [Outgoing]

*** </region>
*-----------------------------------------------------------------------------
* Modification History :
*
* Code Review_Amendment Date   31-12-2020
*
*
* 01/07/2021    KIRAN HS    1.2    REVIEW
*
*-----------------------------------------------------------------------------


*** <region name= Inserts>
*** <desc>Inserts </desc>
    $USING EB.SystemTables
    $USING EB.Logging
    $USING EB.API
    $INSERT I_Logger

*** </region>

*** <region name= Main Process>
*** <desc>Main Process </desc>
    GOSUB initialise
    GOSUB invokeSmsClient
    GOSUB handleFailure

RETURN

*** </region>

*** <region name= Initialise>
*** <desc>Initialisation </desc>
initialise:
* Initialise the source file along with variables
    errorResponse = ''
    calljError = ''
* Initialise logging data
    sContext = "DE.EMAIL.SMS"
    sMessage = ''
    sMessage<EB.Logging.EbLogMsgAppln> = "DE.O.HEADER"
    sMessage<EB.Logging.EbLogMsgRoutine> = "AMR.EMAIL.JAVA.INTERFACE"
    sMessage<EB.Logging.EbLogMsgModule> = "DE"
    sMessage<EB.Logging.EbLogMsgLogParam> = sContext
    className = "com.techmill.integration.EmailAlertsIntegration"
    methodName = "processEmailAlert"

RETURN

*** </region>

*** <region name= InvokeSMSClient>
*** <desc>Invoke SMS Client </desc>
invokeSmsClient:
* Deliver to SMS Carrier
    ebApiId = "DE.SMS.CLIENT"
* Log the delivery message
    sMessage<EB.Logging.EbLogMsgDesc> = "Delivery message"
    sMessage<EB.Logging.EbLogMsgDetails> = deliveryPackage
    sMessage<EB.Logging.EbLogMsgLogLevel> = "INFO"
    Logger.info(sContext, sMessage)

*   CALLJ className,methodName, deliveryPackage SETTING ret ON ERROR GOTO handleFailure

*   Code Review Changes - Changing GOTO to GOSUB

    CALLJ className,methodName, deliveryPackage SETTING ret ON ERROR
        GOSUB handleFailure
    END
    
*    IF (ret EQ 'Message Sent') THEN
*        CRT "Event Triggered, Message Successfully sent to Customer's Phone"
*        RETURN
*    END

    err = SYSTEM(0)
    
    BEGIN CASE
        
        CASE err EQ 1
            errorResponse = "Fatal error creating thread ":ret
            
        CASE err EQ 2
            errorResponse = "Cannot create JVM ":ret
    
        CASE err EQ 3
            errorResponse = "Cannot find class ":ret
    
        CASE err EQ 4
            errorResponse = "Unicode conversion error ":ret
    
        CASE err EQ 5
            errorResponse = "Cannot find method ":ret
    
        CASE err EQ 6
            errorResponse = "Cannot find object constructor ":ret
                        
        CASE err EQ 7
            errorResponse = "Cannot instantiate object ":ret
        
    END CASE
    
RETURN

*** </region>

*** <region name= HandleFailure>
*** <desc>Handle Failure </desc>
handleFailure:
* Return the CALLJ error (if any)
    IF (calljError NE '') THEN
        errorResponse = 'Error in invoking Java interface - CALLJ Error code ':calljError
    END
    IF (errorResponse NE "") THEN
        errorResponse = 'STOP-':errorResponse
* Log the error
        sMessage<EB.Logging.EbLogMsgDesc> = "Response from interface"
        sMessage<EB.Logging.EbLogMsgDetails> = errorResponse
        sMessage<EB.Logging.EbLogMsgLogLevel> = "ERROR"
        Logger.error(sContext, sMessage)
    END

RETURN

*** </region>

END
