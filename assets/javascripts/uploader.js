CommunityEngine.SwfUpload = Class.create({
	initialize: function(upload_url){
		this.swfu = new SWFUpload({
			upload_url : upload_url,
		  flash_url: '/plugin_assets/community_engine/images/swf/swfupload_f9.swf',
		  file_size_limit : '3072',
		  file_types : '*.jpg;*.gif;*.png;*.jpeg',
		  file_types_description : 'Images',
		  file_upload_limit : '5',
		  file_queue_error_handler : this.fileQueueError.bind(this),
		  file_dialog_complete_handler : this.fileDialogComplete.bind(this),
			file_dialog_start_handler: this.fileDialogStart.bind(this),
		  upload_progress_handler : this.uploadProgress,
		  upload_error_handler : this.uploadError.bind(this),
		  upload_success_handler : this.uploadSuccess.bind(this),
		  upload_complete_handler : this.uploadComplete.bind(this),
		  custom_settings : { 
		    upload_target : 'divFileProgressContainer'
		  }, 
			debug: false
		});
	},
	
	uploadErrors: [],
		
	fileDialogStart: function() {
		this.uploadErrors = [];
	},
		
	fileQueueError: function(fileObj, error_code, message) {
		try {
			var error_name = "";			
			switch(error_code) {
				case SWFUpload.QUEUE_ERROR.QUEUE_LIMIT_EXCEEDED:
					error_name = "You have attempted to queue too many files.";
				break;
				default:
				error_name = "Undefined error code: " + error_code + ", message: " + message
				break;
			}
			this.uploadErrors.push(error_name)
			this.showErrors(fileObj);
		} catch (ex) { this.swfu.debug(ex); }
	},
	
	showErrors: function(fileObj){
		if(fileObj){
			var progress = new FileProgress(fileObj,  this.swfu.customSettings.upload_target);
			progress.SetCancelled();
			progress.SetStatus("Stopped");							
		}
		alert('Stopping due to errors! \n' + this.uploadErrors.join('\n '))
	},
	
	fileDialogComplete: function(num_files_queued) {
		try {
			if (num_files_queued > 0) {
				// automatically start uploading after files are selected
				this.swfu.startUpload();
			}
		} catch (ex) { this.swfu.debug(ex); }
	},
	
	uploadProgress: function(fileObj, bytesLoaded) {
		try {
			var percent = Math.ceil((bytesLoaded / fileObj.size) * 100)
			var progress = new FileProgress(fileObj,  this.customSettings.upload_target);
			progress.SetProgress(percent);
			if (percent === 100) {
				progress.SetStatus("Creating thumbnail...");
				progress.ToggleCancel(false);
				progress.ToggleCancel(true, this, fileObj.id);
			} else {
				progress.SetStatus("Uploading...");
				progress.ToggleCancel(true, this, fileObj.id);
			}
		} catch (ex) { this.debug(ex); }
	},
	
	uploadSuccess: function(fileObj, server_data) {
		if (server_data.indexOf('Error') != -1){
			this.uploadErrors.push(server_data)
		} else {
			try {
				AddImage(server_data);
				var progress = new FileProgress(fileObj,  this.swfu.customSettings.upload_target);
				progress.SetStatus("Thumbnail Created.");
				progress.ToggleCancel(false);
			} catch (ex) { this.swfu.debug(ex); }		
		}
	},
		
	uploadComplete: function(fileObj) {
		try {
			/*  I want the next upload to continue automatically so I'll call startUpload here */
			if (this.uploadErrors.size() > 0){
				this.showErrors(fileObj);
			} else if(this.swfu.getStats().files_queued > 0) {
				this.swfu.startUpload();
			} else {
				var progress = new FileProgress(fileObj,  this.customSettings.upload_target);
				progress.SetComplete();
				progress.SetStatus("All images received.");
			}
		} catch (ex) { this.swfu.debug(ex); }
	},
	
	uploadError: function(fileObj, error_code, message) {
		try {
			error_name = '';
			switch(error_code) {
				case SWFUpload.UPLOAD_ERROR.UPLOAD_LIMIT_EXCEEDED:
					error_name = "Upload limit exceeded"
				break;
				case SWFUpload.UPLOAD_ERROR.UPLOAD_FAILED:
					error_name = "Upload failed."
				break;
				case SWFUpload.UPLOAD_ERROR.HTTP_ERROR:
					error_name = "HTTP Error."
				break;				
				default:
					error_name = "Undefined error code: " + error_code + ", message: " + message
				break;
			}
			this.uploadErrors.push(error_name)
		} catch (ex) { this.swfu.debug(ex); }
	}
});


function FileProgress(fileObj, target_id) {
	this.file_progress_id = "divFileProgress";

	this.fileProgressWrapper = document.getElementById(this.file_progress_id);
	if (!this.fileProgressWrapper) {
		this.fileProgressWrapper = document.createElement("div");
		this.fileProgressWrapper.className = "progressWrapper";
		this.fileProgressWrapper.id = this.file_progress_id;

		this.fileProgressElement = document.createElement("div");
		this.fileProgressElement.className = "progressContainer";

		var progressCancel = document.createElement("a");
		progressCancel.className = "progressCancel";
		progressCancel.href = "#";
		progressCancel.style.visibility = "hidden";
		progressCancel.appendChild(document.createTextNode(" "));

		var progressText = document.createElement("div");
		progressText.className = "progressName";
		progressText.appendChild(document.createTextNode(fileObj.name));

		var progressBar = document.createElement("div");
		progressBar.className = "progressBarInProgress";

		var progressStatus = document.createElement("div");
		progressStatus.className = "progressBarStatus";
		progressStatus.innerHTML = "&nbsp;";

		this.fileProgressElement.appendChild(progressCancel);
		this.fileProgressElement.appendChild(progressText);
		this.fileProgressElement.appendChild(progressStatus);
		this.fileProgressElement.appendChild(progressBar);

		this.fileProgressWrapper.appendChild(this.fileProgressElement);

		document.getElementById(target_id).appendChild(this.fileProgressWrapper);
		FadeIn(this.fileProgressWrapper, 0);

	} else {
		this.fileProgressElement = this.fileProgressWrapper.firstChild;
		this.fileProgressElement.childNodes[1].firstChild.nodeValue = fileObj.name;
	}

	this.height = this.fileProgressWrapper.offsetHeight;

}
FileProgress.prototype.SetProgress = function(percentage) {
	this.fileProgressElement.className = "progressContainer green";
	this.fileProgressElement.childNodes[3].className = "progressBarInProgress";
	this.fileProgressElement.childNodes[3].style.width = percentage + "%";
}
FileProgress.prototype.SetComplete = function() {
	this.fileProgressElement.className = "progressContainer blue";
	this.fileProgressElement.childNodes[3].className = "progressBarComplete";
	this.fileProgressElement.childNodes[3].style.width = "";

}
FileProgress.prototype.SetError = function() {
	this.fileProgressElement.className = "progressContainer red";
	this.fileProgressElement.childNodes[3].className = "progressBarError";
	this.fileProgressElement.childNodes[3].style.width = "";

}
FileProgress.prototype.SetCancelled = function() {
	this.fileProgressElement.className = "progressContainer";
	this.fileProgressElement.childNodes[3].className = "progressBarError";
	this.fileProgressElement.childNodes[3].style.width = "";

}
FileProgress.prototype.SetStatus = function(status) {
	this.fileProgressElement.childNodes[2].innerHTML = status;
}

FileProgress.prototype.ToggleCancel = function(show, upload_obj, file_id) {
	this.fileProgressElement.childNodes[0].style.visibility = show ? "visible" : "hidden";
	if (upload_obj) {
		this.fileProgressElement.childNodes[0].onclick = function() { upload_obj.cancelUpload(); return false; };
	}
}

function AddImage(src) {
	var new_img = document.createElement("img");
	new_img.style.margin = "5px";

	document.getElementById("thumbnails").appendChild(new_img);
	if (new_img.filters) {
		try {
			new_img.filters.item("DXImageTransform.Microsoft.Alpha").opacity = 0;
		} catch (e) {
			// If it is not set initially, the browser will throw an error.  This will set it if it is not set yet.
			new_img.style.filter = 'progid:DXImageTransform.Microsoft.Alpha(opacity=' + 0 + ')';
		}
	} else {
		new_img.style.opacity = 0;
	}

	new_img.onload = function () { FadeIn(new_img, 0); };
	new_img.src = src;
}

function FadeIn(element, opacity) {
	var reduce_opacity_by = 15;
	var rate = 30;	// 15 fps


	if (opacity < 100) {
		opacity += reduce_opacity_by;
		if (opacity > 100) opacity = 100;

		if (element.filters) {
			try {
				element.filters.item("DXImageTransform.Microsoft.Alpha").opacity = opacity;
			} catch (e) {
				// If it is not set initially, the browser will throw an error.  This will set it if it is not set yet.
				element.style.filter = 'progid:DXImageTransform.Microsoft.Alpha(opacity=' + opacity + ')';
			}
		} else {
			element.style.opacity = opacity / 100;
		}
	}

	if (opacity < 100) {
		setTimeout(function() { FadeIn(element, opacity); }, rate);
	}
}