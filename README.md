# CodeX Opticom

This Lua script is designed for controlling traffic lights in a game environment. It allows you to interact with traffic lights, change them to green, and automatically reset them to red after a specified duration.

## Features

- Automatically detects nearby traffic lights.
- Sets traffic lights to green when specific conditions are met.
- Resets traffic lights to red after a customizable duration.
- Provides visual notifications for traffic light state changes.

## Parameters

You can customize the script's behavior by adjusting the following parameters in the script:

- `SEARCH_STEP_SIZE`: Step size to search for traffic lights.
- `SEARCH_MIN_DISTANCE`: Minimum distance to search for traffic lights.
- `SEARCH_MAX_DISTANCE`: Maximum distance to search for traffic lights.
- `SEARCH_RADIUS`: Radius to search for traffic lights after translating coordinates.
- `HEADING_THRESHOLD`: Player must match traffic light orientation within this threshold (degrees).
- `TRAFFIC_LIGHT_POLL_FREQUENCY_MS`: Polling frequency (ms) for quicker detection.
- `TRAFFIC_LIGHT_GREEN_DURATION_MS`: Duration to keep the traffic light green (ms).

## Usage

1. Install the script in your game environment.
2. Customize the parameters in the script to match your preferences.
3. Run the script in your game environment.

## Notifications

The script displays on-screen notifications when the traffic light state changes. Notifications include:

- "Traffic light set to green." when a traffic light is set to green.
- "Traffic light reset." when a traffic light is reset to red.

## License

This script is available under the MIT License. See the [LICENSE](LICENSE) file for details.

## Credits

This script was created by [TheStoicBear](https://github.com/TheStoicBear).
