# wallpapper

![wallpaper](Images/wallpaper.png)

This is simple console application for macOS to create dynamic wallpapers introduced in macOS Mojave. [Here](https://www.youtube.com/watch?v=TVqfPzdsbzY) you can watch how dynamic wallpapers works. Also you can read more about dynamic wallpapers in following articles:

- [macOS Mojave dynamic wallpaper](https://itnext.io/macos-mojave-dynamic-wallpaper-fd26b0698223)
- [macOS Mojave dynamic wallpapers (II)](https://itnext.io/macos-mojave-dynamic-wallpapers-ii-f8b1e55c82f)

## Build and install

Open your terminal and run following commands.

```bash
git clone https://github.com/mczachurski/wallpapper.git
cd wallpapper
swift build --configuration release
sudo cp .build/x86_64-apple-macosx10.10/release/wallpapper /usr/local/bin
```

Now in the console you can run `wallpapper -h` and you should got a response similar to the following one.

```bash
wallpapper: [command_option] -i inputFile
Command options are:
 -h			show this message and exit
 -o			output file name (default is 'output.heic')
 -i			input file name, json file with wallpaper description
```

That's all. Now you can build your own dynamic wallpappers.

## Getting started

If you have done above commands now you can build dynamic wallpaper. It's really easy. First you have to put all you pictures into one folder and in the same folder create `json` file with picture's description. `json` file have to have structure like on below snippet.

```json
[
  {
    "fileName": "1.png",
    "isPrimary": true,
    "themeMode": 1,
    "altitude": 27.95,
    "azimuth": 279.66
  },
  {
    "fileName": "2.png",
    "isPrimary": false,
    "themeMode": 1,
    "altitude": -31.05,
    "azimuth": 4.16
  },
  ...
  {
    "fileName": "16.png",
    "isPrimary": false,
    "themeMode": 1,
    "altitude": -28.63,
    "azimuth": 340.41
  }
]
```

Properties:

- `fileName` - name of picture file name.
- `isPrimary` - information about image which is primary image (it will be visible after creating `heic` file). Only one of the file can be primary.
- `themeMode` - information about mode which will display picture. 0 - picture will be displayed in both modes (light/dark). 1 - picture will be displayed only in light mode.
- `altitude` - is the angle between the Sun and the observer's local horizon.
- `azimuth` - that is the angle of the Sun around the horizon.

To calculate proper altitude and azimuth you can use that page: [https://keisan.casio.com/exec/system/1224682277](https://keisan.casio.com/exec/system/1224682277). You have to put place where you take a photo and the date. Then system generate for you altitude and azimuth of the Sun during whole day.

When you have `json` file and all pictures then you can generate `heic` file. You have to run following command:

```bash
wallpapper -i wallpapper.json
```

You should got a new file: `output.heic`. Set this file as a new wallpaper and enjoy you own dynamic wallpaper! 