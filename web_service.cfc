<cfcomponent displayname="Web Service" hint="Encapsulates the web service call to Parature.">


    <!--- =========================================================================== --->

	<!--- GLOBAL VARIABLES --->
        <!--- public --->
        <cfset THIS.sandbox = true />

    <!--- =========================================================================== --->


    <!--- ==================== --->
    <!---   WEB SERVICE CALL   --->
    <!--- ==================== --->   

    <cffunction name="call" access="public" output="false">
        <cfargument name="operation" required="true" type="string" />
        <cfargument name="object" required="true" type="string" />
        <cfargument name="parameters" required="false" type="string" default="" />
        <cfargument name="method" required="false" type="string" default="GET" />
        <cfargument name="body" required="false" type="xml" />
        <cfargument name="return_dump" required="false" type="boolean" default="false" />

        <cfset LOCAL.url = setURL(
            operation = ARGUMENTS.operation,
            object = ARGUMENTS.object,
            parameters = ARGUMENTS.parameters
        ) />
        
        <!--- set GET output to json format --->
        <cfif ARGUMENTS.method eq "GET">
            <cfset LOCAL.url = "#LOCAL.url#&_output_=json" />
        </cfif>

        <cfhttp url="#LOCAL.url#" method="#ARGUMENTS.method#" result="LOCAL.return">
            <cfif StructKeyExists(ARGUMENTS, "body") and isXml(ARGUMENTS.body)>
                <cfhttpparam type="xml" value="#ARGUMENTS.body#" />
            </cfif>
        </cfhttp>

        <cfif not ARGUMENTS.return_dump>
            <cfset LOCAL.return = formatOutput(LOCAL.return, ARGUMENTS.method) />
        </cfif>

        <cfreturn LOCAL.return />

    </cffunction>


    <!--- ============================= --->
    <!---   FORMAT WEB SERVICE OUTPUT   --->
    <!--- ============================= --->

    <cffunction name="formatOutput" access="private" output="false" returntype="struct">
        <cfargument name="return" required="true" type="struct" />
        <cfargument name="method" required="true" type="string" />
        
        <cftry>
        
        <cfset LOCAL.filecontent = ARGUMENTS.return.filecontent />

        <!--- PARATURE DOESN'T RETURN ALL CALLS IN JSON.  SOME ARE XML.
              SO WE MAKE SURE NO MATTER THE RETURN FORMAT, WE ARE SENDING
              BACK A STRUCT --->
        <cfif isXML(LOCAL.filecontent)>
            <cfset LOCAL.return.xml = xmlparse(REReplace(LOCAL.filecontent, "^[^<]*", "", "all" )) />
            <cfset LOCAL.return.xml = LOCAL.return.xml.xmlroot />
        <cfelseif isJSON(LOCAL.filecontent)>
            <cfset LOCAL.return = deserializeJSON(LOCAL.filecontent) />
        <cfelse>
            <cfset LOCAL.return = LOCAL.filecontent />
        </cfif> 
        
        <cfif isStruct(LOCAL.return)
          and StructKeyExists(LOCAL.return, "Entities")>
            <cfset LOCAL.return = LOCAL.return.entities />
        </cfif>

        <cfreturn LOCAL.return />
            
        <cfcatch>
            <cfmail to="support@finalsite.com" from="widget@staff.finalsite.com" type="html" subject="Widget Error (FormatOutput)">
                <h1>Arguments</h1>
                <cfdump var="#arguments#" />
                <h1>Local</h1>
                <cfdump var="#local#" />
                <h1>Error</h1>
                <cfdump var="#cfcatch#" />
            </cfmail>
        </cfcatch>
        </cftry>

    </cffunction>


    <!--- =============== --->
    <!---   GET API URL   --->
    <!--- =============== --->  

    <cffunction name="setURL" access="public" output="false" returnType="string">
        <cfargument name="operation" required="true" type="string" />
        <cfargument name="object" required="true" type="string" />
        <cfargument name="parameters" required="false" type="string" default="" />
        <cfargument name="account" required="false" type="string" default="3870" />
        <cfargument name="department" required="false" type="string" default="4205" />

        <!--- switch domain & token (API USER Parature Account) if we're testing in sandbox --->
        <cfif THIS.sandbox>
            <cfset LOCAL.domain = "https://sco-sandbox.parature.com/api/v1" />
            <cfset LOCAL.token = "_token_=[APIKEY]" />
        <cfelse>
            <cfset LOCAL.domain = "https://supportcenteronline.com/api/v1" />
            <cfset LOCAL.token = "_token_=[APIKEY]" />
        </cfif>

        <!--- add ampersand to params if it wasn't added --->
        <cfif len(trim(ARGUMENTS.parameters)) and left(ARGUMENTS.parameters, 1) neq "&">
            <cfset ARGUMENTS.parameters = "&#ARGUMENTS.parameters#" />
        </cfif>

        <!--- structure uri based on operation --->
        <cfswitch expression="#trim(ARGUMENTS.operation)#">
            <cfcase value="list">
                <cfset LOCAL.url = "#LOCAL.domain#/#ARGUMENTS.account#/#ARGUMENTS.department#/#ARGUMENTS.object#?#LOCAL.token##ARGUMENTS.parameters#">
            </cfcase>
            <cfcase value="schema">
                <cfset LOCAL.url = "#LOCAL.domain#/#ARGUMENTS.account#/#ARGUMENTS.department#/#ARGUMENTS.object#/#LOCAL.operation#?#LOCAL.token##ARGUMENTS.parameters#">
            </cfcase>
            <cfdefaultcase>
                <cfset LOCAL.url = "#LOCAL.domain#/#ARGUMENTS.account#/#ARGUMENTS.department#/#ARGUMENTS.operation#/#ARGUMENTS.object#?#LOCAL.token##ARGUMENTS.parameters#">
            </cfdefaultcase>
        </cfswitch>

        <cfreturn LOCAL.url />
    </cffunction>


</cfcomponent>
