$( function() {

	ticketNumber = $.urlParam('ticketNumber');
    $('button').button();

    /* EDITED BY BLAKE 8/23/15 */
    /* LOAD THE QUICK EDIT VIEW */
    $(document).ready(function(){

        var namespace = 'ticket_update',
            id = '#' + namespace

        $('#tabs').tabs({ fx: { opacity: 'toggle' } });

        $(id).load('quick_update_get.cfm?ticketNumber=' + ticketNumber, function(){

            /* Convert dropdowns to fancy jquery dropdowns */
            $(id + ' select').chosen({width: '240px'});

            /* Enable Datepicker */
            $(id + ' input.datepicker').datepicker({
                minDate: '+1'
            });

            /* Convert submit button to jQuery button to match widget flavor */
            $(id + ' button').button()

            $( "form" ).on( "submit", function( event ) {
                event.preventDefault();
                $(id + ' button').children().text('Saving...');

                $.ajax({
                    url: 'quick_update_set.cfm',
                    data: $( this ).serialize(),
                    success: function(data){
                        $(id + ' button').css('background', '#2AB530').children().text('Success');
                        setTimeout(function(){
                            $(id + ' button').css('background', '').children().text('Update');
                        }, 5000);
                    }
                });

            });

        });
    });

	//console.log(ticketNumber);
	$('#parajiraBugLink').attr('href', 'http://staff.finalsite.com/custom/parajira/?task_id=1&ticket_id=' + ticketNumber);
	$('#parajiraERQLink').attr('href', 'http://staff.finalsite.com/custom/parajira/?task_id=4&ticket_id=' + ticketNumber);

	$.get( 'getTicketData.cfm?ticketNumber=' + ticketNumber, function( data ){
		//console.log(data);
		console.log(data);
		$('#serverData').html( data );

		var ticket = $.parseJSON( data );

        console.log(ticket.customer);

		//$('.clientName').text( ticket.customer.firstName + ' ' + ticket.customer.lastName );
		$('#copyNum span').text( 'Copy "' + ticket.number + '" to Clipboard').attr('data-copy-value', ticket.number);
		$('#copyGit span').text( 'Copy "git checkout clients/' + ticket.customer.account.keyword + '"').attr('data-copy-value', 'git checkout clients/' + ticket.customer.account.keyword);



		$('.role').text( ticket.customer.role );
		$('.position').text( ticket.customer.position );
		$('.finalsiteAdminID').text( ticket.customer.finalsiteAdminID );
		$('.finalsiteAdminUsername').text( ticket.customer.finalsiteAdminUsername );
		$('.finalsiteAdminGroup').text( ticket.customer.finalsiteAdminGroup );
		$('.phone').text( ticket.customer.phone );

		$('.vip').text(  ticket.customer.vip == 1 ? "Yes" : "No" );
		if ( ticket.customer.vip == 1 ) {
			$('#tabs-1 .clientName').after("<span><strong> - VIP</strong></span>");
		}

		if (ticket.customer.gender == 'Male') {
			console.log('Gender: Male');
			$('#genderSymbol').attr('src', 'icons/MaleSymbol.png');
		}
		if (ticket.customer.gender == '') {
			console.log("Gender Unknown");
			$('#genderSymbol').hide();
		}

		$('#age').text( parseMinutes(workingMinutesBetweenDates( new Date(ticket.dateCreated), new Date() ) ));

		if (typeof ticket.customer.account.url !== 'undefined') {
			$('.accountName').text( ticket.customer.account.name );
			$('#server').text( ticket.customer.account.server );
			$('.keyword').text( ticket.customer.account.keyword );
			$('#siteURL').attr('href',ticket.customer.account.url).text( ticket.customer.account.url );
			$('#adminURL').attr('href',ticket.customer.account.url + '/admin/fs');
			$('.redesignLink').attr('href','http://' + ticket.customer.account.keyword + '.redesign.finalsite.com/admin/fs');
			$('.applyLink').attr('href','http://' + ticket.customer.account.keyword + '.finalsiteapply.com');
			$('#address').text( ticket.customer.account.address1 );
			$('#city').text( ticket.customer.account.city );
			$('.state').text( ticket.customer.account.state );
			$('#zip').text( ticket.customer.account.zip );
			$('.country').text( ticket.customer.account.country );
			$('.timeZone').text( ticket.customer.account.timeZone );
			$('#projectManager').text( ticket.customer.account.projectManager );
			$('.redirectIP').text( ticket.customer.account.redirectIP );
			$('.happiness').text( ticket.customer.account.happiness );
			$('.clientSuccessManager').text( ticket.customer.account.clientSuccessManager );
			$('.customerID').text( ticket.customer.id );


			baseURL = ticket.customer.account.sf_url.replace('http://','');
			baseURL = baseURL.replace('www.','');
			baseURL = baseURL.replace(/\/$/, "");
			$('.publicURL').text( baseURL );



			//Restore Database links
			var serverNum = ticket.customer.account.server.split("cf")[1];
			$("#dbRestoreLinkDaily").attr("href", "http://cfaux01/devtools/restore/?sqlserver=CFSQL"+serverNum).text("View Daily List for CFSQL"+serverNum);
			$("#dbRestoreLinkHourly").attr("href", "http://cfaux01/devtools/restore/?sqlserver=CFSQL"+serverNum+"&backuptype=hourly").text("View Hourly List for CFSQL"+serverNum);


			dsPercent = Math.floor( (ticket.customer.account.diskSpaceUsed / ticket.customer.account.diskSpaceMax)  * 100 );
			$('#diskSpace').text( ticket.customer.account.diskSpaceUsed + ' out of ' + ticket.customer.account.diskSpaceMax + ' MB used. (' + dsPercent + '%)' );
			$('#cdn').text( ( ticket.customer.account.cdn == 1 ? "On" : "Off" ) );
			$('#accelerator').text( ( ticket.customer.account.accelerator == 1 ? "On" : "Off" ) );
			$('#googleAccountID').text( ticket.customer.account.googleAccountID );
			$('#paratureID').text( ticket.customer.account.id );
			$('#internalNotes').html( ticket.customer.account.notes );
					$('#clearCacheLink').attr('href','http://cfaux01/devtools/clearcache/?server=' + ticket.customer.account.server + '&path=' + ticket.customer.account.keyword).text('Clear Cache for '+ticket.customer.account.keyword+' on ' + ticket.customer.account.server);

			$('#appVariablesLink').attr('href', ticket.customer.account.url + '/appvariables.cfm');

			$('#siteErrorLink').attr('href', 'http://cfaux01/devtools/errors/?submitted=all&site=' + ticket.customer.account.name);

			//TAGS
			if (ticket.customer.account.theme) { $('#themeTag').show(); }
			if (ticket.customer.account.composer) { $('#composerTag').show(); }
			if (!ticket.customer.account.cdn) { $('#cdnDisabledTag').show(); }
			if (ticket.customer.account.accelerator) { $('#acceleratorTag').show(); }
			if (ticket.customer.account.composer_redesign) { $('#redesignTag').show(); }
			if (dsPercent > 75 && dsPercent != "Infinity") { $('#lowDiskSpaceTag').show(); }
			if ( ticket.customer.account.name.indexOf('Association') > 0) { $('#associationTag').show(); }
			if ( ticket.customer.account.sis.length > 0 && ticket.customer.account.sis != 'None') { $('#sisTag').text('SIS: ' + ticket.customer.account.sis).show(); }
			if ( ticket.customer.account.apply) { $('#applyTag').show(); }


			} else {
				$('#siteURL').hide();
				$('#adminURL').hide();
				$('#clearCacheLink').hide();
				$('#appVariablesLink').hide();
				$('#siteErrorLink').hide();
				$('#dbRestoreLinkDaily').hide();
				$('#dbRestoreLinkHourly').hide();
			}
		var recipient = ticket.assignedTo.replace( ' ', '.').toLowerCase() + '@finalsite.com';
		if (recipient == "system@finalsite.com") { recipient = "support@finalsite.com"; }
		var sdLink = 'http://www.supportdetails.com?sender_name=' + ticket.customer.firstName + '%20' + ticket.customer.lastName + '&sender=' + ticket.customer.email + '&recipient=' + recipient;
		$('#supportDetailsLink').attr('href', sdLink).text( sdLink );


		$("#loadingDiv").fadeOut();

		$('.copyLink').click( function() {
			copyToClipboard( $(this).find('span').attr('data-copy-value') );
		});

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

function copyToClipboard(text) {
  window.prompt("Press Ctrl/Cmd + C to copy to clipboard.", text);
}

function parseMinutes( mins ) {
	var days = Math.floor( mins / 60 / 24 );
	mins = mins - (days * 60 * 24);
	var hours = Math.floor( mins / 60 );
	var minutes = mins - (hours*60);

	var dateString = days;
	dateString += (days == 1) ? " day, ":" days, ";
	dateString += hours;
	dateString += (hours == 1) ? " hour, ":" hours, ";
	dateString += minutes;
	dateString += (minutes == 1) ? " minute":" minutes";
	console.log(dateString);
	return dateString;
}

// Simple function that accepts two parameters and calculates the number of hours worked within that range
function workingMinutesBetweenDates(startDate, endDate) {
    // Store minutes worked
    var minutesWorked = 0;

    // Validate input
    if (endDate < startDate) { return 0; }

    // Loop from your Start to End dates (by hour)
    var current = startDate;

    // Define work range
    var workHoursStart = 8;
    var workHoursEnd = 19;
    var includeWeekends = false;

    // Loop while currentDate is less than end Date (by minutes)
    while(current <= endDate){
        // Is the current time within a work day (and if it occurs on a weekend or not)
        if(current.getHours() >= workHoursStart && current.getHours() <= workHoursEnd && (includeWeekends ? current.getDay() !== 0 && current.getDay() !== 6 : true)){
              minutesWorked++;
        }

        // Increment current time
        current.setTime(current.getTime() + 1000 * 60);
    }

    // Return the number of hours
    return minutesWorked;
}
