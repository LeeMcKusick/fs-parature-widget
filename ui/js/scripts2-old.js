$( function() {
	$('#tabs').tabs({ fx: { opacity: 'toggle' } });
	$('button').button();  

	//console.log( $.urlParam('ticketNum') );

	var firstName =  $.urlParam('firstName');
	var lastName =  $.urlParam('lastName');
	var accountID = $.urlParam('accountID');
	var ticketNum = $.urlParam('ticketNumber');
	
	
	$('#clientName').text( firstName + ' ' + lastName );

	$('#parajiraBugLink').attr('href','http://staff.finalsite.com/custom/parajira/?task_id=1&ticket_id=' + ticketNum);
	$('#parajiraERQLink').attr('href','http://staff.finalsite.com/custom/parajira/?task_id=4&ticket_id=' + ticketNum);
	
	
	$.get( 'getBasicAccountInfo.cfm?accountID=' + accountID, function( data ){
		
		console.log( data );
		$('#serverData').html( data );
		
		var account = $.parseJSON( data );
	
		//console.log(ticket);
		$('#accountName').text( account.name );
		$('#server').text( account.server );
		$('.keyword').text( account.keyword );
		$('#siteURL').attr('href', account.url).text( account.url );
		$('#adminURL').attr('href',account.url + '/admin/fs');
		$('#address').text( account.address1 );
		$('#city').text( account.city );
		$('.state').text( account.state );
		$('#zip').text( account.zip );
		$('.country').text( account.country );
		$('.timeZone').text( account.timeZone );
		$('#projectManager').text( account.projectManager );
		$('.redirectIP').text( account.redirectIP );
		$('.happiness').text( account.happiness );
		
		//if (ticket.customer.gender == 'Male') { 
			//$('#genderSymbol').attr('src', 'icons/MaleSymbol.png');
		//}
		baseURL = account.url.replace('http://','');
		baseURL = baseURL.replace('www.','');
		$('.publicURL').text( baseURL );

		
		//Restore Database links
		var serverNum = account.server.split("cf")[1];	
		$("#dbRestoreLinkDaily").attr("href", "http://cfaux01/devtools/restore/?sqlserver=CFSQL"+serverNum).text("View Daily List for CFSQL"+serverNum);
		$("#dbRestoreLinkHourly").attr("href", "http://cfaux01/devtools/restore/?sqlserver=CFSQL"+serverNum+"&backuptype=hourly").text("View Hourly List for CFSQL"+serverNum);

		
		dsPercent = Math.floor( (account.diskSpaceUsed / account.diskSpaceMax)  * 100 );
		$('#diskSpace').text( account.diskSpaceUsed + ' out of ' + account.diskSpaceMax + ' MB used. (' + dsPercent + '%)' );
		$('#cdn').text( ( account.cdn == 1 ? "On" : "Off" ) );
		$('#accelerator').text( ( account.accelerator == 1 ? "On" : "Off" ) );
		$('#paratureID').text( account.id );
		$('#internalNotes').html( account.notes );
		
		
		//var sdLink = 'http://www.supportdetails.com?sender_name=' + ticket.customer.firstName + '%20' + ticket.customer.lastName + '&sender=' + ticket.customer.email + '&recipient=' + ticket.assignedTo.replace( ' ', '.').toLowerCase() + '@finalsite.com';
		//$('#supportDetailsLink').attr('href', sdLink).text( sdLink );
	
		$('#clearCacheLink').attr('href','http://cfaux01/devtools/clearcache/?server=' + account.server + '&path=' + account.keyword).text('Clear Cache for '+account.keyword+' on ' + account.server);
		
		$('#siteErrorLink').attr('href', 'http://cfaux01/devtools/errors/?submitted=all&site=' + account.name);
		
		
		
	
	});
	
});

$.urlParam = function(name){
    var results = new RegExp('[\?&]' + name + '=([^&#]*)').exec(window.location.href);
    if (results==null){
       return null;
    }
    else{
       return results[1] || 0;
    }
}
