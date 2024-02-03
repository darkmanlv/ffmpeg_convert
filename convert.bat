@echo off
setlocal enabledelayedexpansion

set "input_output_folder=c:\path_to_folder"

if not exist "%input_output_folder%" (
    echo Input/output folder does not exist. Exiting...
    exit /b 1
)

for /r "%input_output_folder%" %%i in (*.mp4) do (
    set "input_file=%%i"
    set "filename=%%~ni"
    set "output_file=!input_output_folder!\!filename!_compressed.mp4"

    REM Skip files that already have "_compressed" in their filenames
    if not "!filename!"=="!filename:_compressed=!" (
        echo Skipping already compressed file: "!input_file!"
    ) else (
        REM Check the size of the input and compressed files
        for %%A in ("!input_file!", "!output_file!") do (
            set "size=0"
            for /f "usebackq" %%B in ('"%%~zA"') do set "size=%%B"
        )

        REM Compress the video using FFmpeg
        ffmpeg -hwaccel_output_format cuda -c:v h264_cuvid -i "!input_file!" -c:v h264_nvenc -vf scale=1280:-1 -b:v 2000k -maxrate 2000k -bufsize 4000k -c:a aac -b:a 128k "!output_file!"

        REM Check if the compression was successful
        if not errorlevel 1 (
            REM Check if the size of the compressed file is larger than the input file
            for %%C in ("!output_file!") do (
                set "compressed_size=0"
                for /f "usebackq" %%D in ('"%%~zC"') do set "compressed_size=%%D"
            )

            if !compressed_size! geq !size! (
                echo Compression successful for: "!input_file!"
                REM Optionally, you can delete the input file here
                REM del /f /q "!input_file!"
            ) else (
                echo Compression not beneficial, reverting changes: "!input_file!"
                REM Remove the compressed file
                if exist "!output_file!" (
                    echo Removing existing output file: "!output_file!"
                    del /f /q "!output_file!"
                )
                REM Rename the input file as compressed
                ren "!input_file!" "!filename!_compressed.mp4"
            )
        ) else (
            echo Error compressing: "!input_file!"
        )
    )
)

echo "Compression completed."
