# Flow Rate Calculator

Desktop app for 3D printer flow rate calibration. Guides you through rough and fine calibration passes to find the optimal flow rate value.

![GitHub release](https://img.shields.io/github/v/release/iSTAYERi/flow-rate-calculator)
![License](https://img.shields.io/github/license/iSTAYERi/flow-rate-calculator)

## Download

Get the latest installer from [Releases](https://github.com/iSTAYERi/flow-rate-calculator/releases/latest).

## How it works

1. Enter your current flow rate
2. Print the calibration model, select the result in **Rough Calibration**
3. Print again, select the result in **Fine Calibration**
4. Copy the final value and apply it in your slicer

## Stack

- [Tauri v2](https://tauri.app) — desktop framework
- [SvelteKit](https://kit.svelte.dev) + TypeScript — frontend
- Svelte 5 runes

## Development

```bash
npm install
npm run tauri dev
```

## Build

```bash
build.bat
# or
npm run tauri build
```

## License

MIT
