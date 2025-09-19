try:
    import sounddevice as sd
except Exception:
    sd = None


def main():
    if sd is None:
        print("PortAudio/sounddevice not available. Install system package 'portaudio19-dev' and pip install sounddevice.")
        return
    devices = sd.query_devices()
    print("Input devices:")
    for idx, d in enumerate(devices):
        if d.get('max_input_channels', 0) > 0:
            print(f"{idx}: {d['name']} (in={d['max_input_channels']}, out={d['max_output_channels']})")


if __name__ == '__main__':
    main()
