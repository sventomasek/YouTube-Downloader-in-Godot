extends Control

@onready var video_url = $VideoURL
@onready var download_path = $DownloadPath
@onready var file_format = $FileFormat
@onready var status = $Status
@onready var exe_path = OS.get_executable_path().get_base_dir()

func _ready():
	status.text = ""
	download_path.text = PlayerPrefs.get_pref("DownloadPath", exe_path)
	
	# Download dependencies and check if YtDlp is ready
	if !YtDlp.is_setup():
		YtDlp.setup()
		await YtDlp.setup_completed
		
func _on_download_pressed():
	var download
	var url = video_url.text
	var file_name = "Downloaded Video"
	var file_path = download_path.text + "\\"
	
	# Check if a file with the same name already exists, change file_name if needed
	var i = 0
	while FileAccess.file_exists(file_path + file_name + "." + file_format.text):
		i += 1
		file_name = "Downloaded Video " + str(i)
		
	# Start the download
	match file_format.text:
		"mp4":
			download = YtDlp.download(url) \
				.set_destination(file_path) \
				.set_file_name(file_name) \
				.set_video_format(YtDlp.Video.MP4) \
				.start()
		"webm":
			download = YtDlp.download(url) \
				.set_destination(file_path) \
				.set_file_name(file_name) \
				.set_video_format(YtDlp.Video.WEBM) \
				.start()
		"mp3":
			download = YtDlp.download(url) \
				.set_destination(file_path) \
				.set_file_name(file_name) \
				.convert_to_audio(YtDlp.Audio.MP3) \
				.start()
		"wav":
			download = YtDlp.download(url) \
				.set_destination(file_path) \
				.set_file_name(file_name) \
				.convert_to_audio(YtDlp.Audio.WAV) \
				.start()
				
	assert(download.get_status() == YtDlp.Download.Status.DOWNLOADING)
	status.text = "Downloading..."
	status.add_theme_color_override("font_color", Color.YELLOW)
	await download.download_completed
	
	# End of download
	status.text = "Download Complete!"
	status.add_theme_color_override("font_color", Color.GREEN)
	
func _on_reset_path_pressed():
	download_path.text = exe_path
	_on_download_path_text_changed(download_path.text)
	
func _on_download_path_text_changed(new_text):
	PlayerPrefs.set_pref("DownloadPath", new_text)
