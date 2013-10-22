## Usage

### CLI

#### View devices

`air list`
```text
* Apple TV (AppleTV2,1 running 11A502)
  ip: 192.168.1.12
  resolution: 1280x720
```

#### Play a video

`air play [url to video or local file]`
```text
Playing http://movietrailers.apple.com/movies/universal/rush/rush-tlr3_480p.mov?width=848&height=352
Time: 00:00:13 [=====                                              ] 7% Apple TV
```

### Show images

`air view [url to image or image folder]`

### Library

#### Finding devices

```ruby
require "airplay"

Airplay.devices.each do |device|
  puts device.name
end
```

#### Sending images

```ruby
require "airplay"

apple_tv = Airplay["Apple TV"]
apple_tv.view("my_image.png")
apple_tv.view("url_to_the_image", transition: "Dissolve")

# View all transitions
apple_tv.transitions
```

#### Playing video

```ruby
require "airplay"

apple_tv = Airplay["Apple TV"]
trailer = "http://movietrailers.apple.com/movies/dreamworks/needforspeed/needforspeed-tlr1xxzzs2_480p.mov"

player = apple_tv.play(trailer)

# Wait until the video is finished
player.wait

# Actions
player.pause
player.resume
player.stop
player.scrub

# Access the playback time per second
player.progress -> progress {
  puts "I'm viewing #{progress["position"]} of #{progress["duration"]}"
}
```