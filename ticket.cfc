<cfcomponent displayname="Ticket" extends="Web_Service">


    <!--- =========================================================================== --->
    <!--- =========================================================================== --->
    <!--- =========================================================================== --->
    <!--- =========================================================================== --->
    <!--- =========================================================================== --->

                                                             <!--- GLOBAL CONSTANTS --->
    <cfset THIS.SCHEMA = getSchema() />


    <!--- =========================================================================== --->
    <!--- =========================================================================== --->
    <!--- =========================================================================== --->
    <!--- =========================================================================== --->
    <!--- =========================================================================== --->



    <!--- ======================= --->
    <!---   INITIALIZE A TICKET   --->
    <!--- ======================= --->

    <cffunction name="init" access="public" output="false" returnType="component">
        <cfargument name="ticket_id" required="false" type="numeric" default="0" />
        <cfargument name="parameters" required="false" type="string" default="" />
        <cfargument name="sandbox" required="false" type="boolean" default="true" />

        <cfif ARGUMENTS.ticket_id>
            <cfset THIS.ticket = call(
                operation = "Ticket",
                object = arguments.ticket_id,
                parameters = arguments.parameters
            ) />
        </cfif>
        
        <cfset this.sandbox = arguments.sandbox />

        <cfreturn THIS />
    </cffunction>
    
    
    <!--- ============== --->
    <!---   GET SCHEMA   --->
    <!--- ============== --->
    
    <cffunction name="getSchema" access="public" output="false" returntype="struct">
        
        <cfset LOCAL.return = call(
            operation = "Ticket",
            object = "schema"
        ) />
    
        <cfreturn LOCAL.return />
    </cffunction>


    <!--- ============ --->
    <!---   GET LIST   --->
    <!--- ============ --->
    
    <cffunction name="getList" access="public" output="false" returntype="struct">
        <cfargument name="parameters" type="string" required="false" default="" />
        
        <cfset LOCAL.return = call(
            operation = "List",
            object = "Ticket",
            parameters = ARGUMENTS.parameters
        ) />
    
        <cfreturn LOCAL.return />
    </cffunction>
    
    
    <!--- =================== --->
    <!---   GET STATUS LIST   --->
    <!--- =================== --->
    
    <cffunction name="getStatusList" access="public" output="false" returntype="struct">
        <cfargument name="parameters" type="string" required="false" default="" />
    
        <cfset LOCAL.return = call(
            operation = "Ticket",
            object = "status",
            parameter = ARGUMENTS.parameters
        ) />
    
        <cfreturn LOCAL.return />
    </cffunction>
    
    
    <!--- ========================= --->
    <!---   GET TICKET QUEUE LIST   --->
    <!--- ========================= --->
    
    <cffunction name="getTicketQueueList" access="public" output="false" returntype="struct">
        <cfargument name="parameters" type="string" required="false" default="" />
    
        <cfset LOCAL.return = call(
            operation = "List",
            object = "Queue",
            parameters = ARGUMENTS.parameters  
        ) />
    
        <cfreturn LOCAL.return />
    </cffunction>
    
    
    <!--- ===================== --->
    <!---   GET FIELD OPTIONS   --->
    <!--- ===================== --->
    
    <cffunction name="getFieldOptions" access="public" output="false" returntype="array">
        <cfargument name="field" type="string" required="true" />
        <cfargument name="schema" type="struct" required="false" default="#THIS.SCHEMA#" />
        
        <cfset LOCAL.return = ArrayNew(1) />

        <cfset LOCAL.fields = StructFindValue(ARGUMENTS.schema, ARGUMENTS.field, "all") />
        
        <cfloop array="#LOCAL.fields#" index="LOCAL.field">
            <cfif LOCAL.field.owner['@display-name'] eq ARGUMENTS.field>
                <cfset LOCAL.return = LOCAL.field.owner.option />
                <cfbreak />
            </cfif>
        </cfloop>
    
        <cfreturn LOCAL.return />
    </cffunction>
    
    
    <!--- ======================= --->
    <!---   GET FIELD SELECTION   --->
    <!--- ======================= --->
    
    <cffunction name="getFieldSelection" access="public" output="false" returntype="string">
        <cfargument name="ticket" type="struct" required="true" />
        <cfargument name="field" type="string" required="true" />
        
        <cfset LOCAL.field = StructNew() />
        
        <!--- GET ALL OPTIONS INCLUDING THE SELECTED ONE --->
        <cfset LOCAL.field.options = getFieldOptions(
            field = ARGUMENTS.field,
            schema = ARGUMENTS.ticket
        ) />
        
        <!--- EXTRACT THE SELECTED VALUE --->
        <cfset LOCAL.return = StructFindKey(LOCAL.field, "@selected", "all") />
        
        <cfif arrayLen(LOCAL.return)>
            <cfset LOCAL.return = LOCAL.return[1].owner.value />
        <cfelse>
            <cfset LOCAL.return = "" />
        </cfif>
    
        <cfreturn LOCAL.return />
    </cffunction>


    <!--- =============== --->
    <!---   EDIT TICKET   --->
    <!--- =============== --->

    <cffunction name="edit" access="public" output="false" returnType="any">
        <cfargument name="ticket_id" required="true" type="numeric" />
        <cfargument name="action_id" required="false" type="numeric" />
        <cfargument name="assigned_csr_id" required="false" type="numeric" />
        <cfargument name="assigned_queue_id" required="false" type="numeric" />
        <cfargument name="comment" required="false" type="string" default="Default Comment" />
        <cfargument name="customer_id" required="false" type="numeric" />
        <cfargument name="show_to_customer" required="false" type="string" default="false" />
        <cfargument name="fields" required="false" type="array" />
        <cfargument name="parameters" required="false" type="string" default="_enforceRequiredFields_=false" />

        <cfsavecontent variable="LOCAL.xml">
            <cfoutput>
                <Ticket id="#ARGUMENTS.ticket_id#">
                    <cfif isDefined("ARGUMENTS.customer_id")>
                        <Ticket_Customer>
                            <Customer id="#ARGUMENTS.customer_id#"></Customer>
                        </Ticket_Customer>
                    </cfif>
                    <cfif isDefined("ARGUMENTS.action_id")>
                        <Action>
                            <Action id="#ARGUMENTS.action_id#">
								<cfif isDefined("ARGUMENTS.assigned_csr_id")>	
									<AssignToCsr>#ARGUMENTS.assigned_csr_id#</AssignToCsr>
                                </cfif>
								<cfif isDefined("ARGUMENTS.assigned_queue_id")>	
									<AssignToQueue>#ARGUMENTS.assigned_queue_id#</AssignToQueue>
                                </cfif>
								<ShowToCust>#ARGUMENTS.show_to_customer#</ShowToCust>
                   				<Comment>#ARGUMENTS.comment#</Comment>
                            </Action>
                        </Action>
                    </cfif>
                    <cfif isDefined("ARGUMENTS.fields")>
                        <cfloop array="#ARGUMENTS.fields#" index="field">
                            #field#
                        </cfloop>
                    </cfif>
                </Ticket>
            </cfoutput>
        </cfsavecontent>

        <cfset LOCAL.return = call(
            operation = "Ticket",
            object = ARGUMENTS.ticket_id,
            parameters = ARGUMENTS.parameters,
            method = "PUT",
            body = LOCAL.xml
        ) />

        <cfreturn LOCAL.return />
    </cffunction>

</cfcomponent>