<cfcomponent displayname="Web Service" hint="Encapsulates the web service call to Parature.">


    <!--- =========================================================================== --->

    <!--- GLOBAL CONSTANTS --->

    <cfset VARIABLES.KEY = "[KEY]" />
    <cfset VARIABLES.TOKEN = "[API TOKEN]" />
    <cfset VARIABLES.DOMAIN = "https://api.trello.com/1" />

    <!--- =========================================================================== --->


    <!--- ==================== --->
    <!---   WEB SERVICE CALL   --->
    <!--- ==================== --->   

    <cffunction name="call" access="public" output="false">
        <cfargument name="model" type="string" required="true" />
        <cfargument name="parameters" type="string" required="false" default="" />
        <cfargument name="method" type="string" required="false" default="GET" />
        <cfargument name="return_dump" type="boolean" required="false" default="false" />
        
        <cfset LOCAL.url = "#VARIABLES.DOMAIN#/#ARGUMENTS.model#?"
                         & "key=#VARIABLES.KEY#"
                         & "&token=#VARIABLES.TOKEN#" />
        
        <cfif len(ARGUMENTS.parameters)>
            <cfset LOCAL.url = "#LOCAL.url#&#ARGUMENTS.parameters#" />
        </cfif>
        
        <cfhttp method="#ARGUMENTS.method#" result="LOCAL.return" url="#LOCAL.url#" />
        
        <cfif not ARGUMENTS.return_dump
          and isStruct(LOCAL.return)
          and StructKeyExists(LOCAL.return, "FileContent")
          and isJSON(LOCAL.return.filecontent)>
            <cfset LOCAL.return = deserializeJSON(LOCAL.return.filecontent) />
        </cfif>

        <cfreturn LOCAL.return />

    </cffunction>


</cfcomponent>
