#!/usr/bin/env python3
"""Generate an original 7-minute stereo forest ambience master for GTA GHIBLI.

The WAV is a genuine 48 kHz / 24-bit PCM source asset. It is deliberately kept
in a .gdignore folder so Godot does not import the large production master
into the Android build. A trimmed/compressed runtime derivative can be made
from this source when the audio team is ready.
"""
from __future__ import annotations

import math
import os
import wave
from pathlib import Path

import numpy as np

SAMPLE_RATE = 48_000
DURATION_SECONDS = 7 * 60
CHANNELS = 2
SAMPLE_WIDTH = 3
OUTPUT = Path("audio/ambience/source_master/willow_forest_day_master_07min.wav")
CHUNK_SECONDS = 1
TAU = 2.0 * math.pi
EXPECTED_DATA_BYTES = SAMPLE_RATE * DURATION_SECONDS * CHANNELS * SAMPLE_WIDTH


def make_events(rng: np.random.Generator) -> tuple[list[tuple[float, float, float, float, float]], list[tuple[float, float, float]]]:
    """Return bird chirp events and soft foliage-rustle events."""
    birds: list[tuple[float, float, float, float, float]] = []
    t = 3.0
    while t < DURATION_SECONDS - 3.0:
        t += float(rng.uniform(2.0, 5.5))
        syllables = int(rng.integers(2, 5))
        base_frequency = float(rng.uniform(2300.0, 3900.0))
        pan = float(rng.uniform(-0.82, 0.82))
        for syllable in range(syllables):
            start = t + syllable * float(rng.uniform(0.11, 0.21))
            duration = float(rng.uniform(0.075, 0.16))
            frequency = base_frequency + float(rng.uniform(-260.0, 260.0))
            sweep = float(rng.uniform(-900.0, 1200.0))
            birds.append((start, duration, frequency, sweep, pan))
        t += float(rng.uniform(1.0, 3.0))

    rustles: list[tuple[float, float, float]] = []
    t = 1.5
    while t < DURATION_SECONDS - 1.0:
        t += float(rng.uniform(1.8, 6.8))
        rustles.append((t, float(rng.uniform(0.35, 1.4)), float(rng.uniform(0.035, 0.095))))
    return birds, rustles


def render_chunk(
    start_frame: int,
    frame_count: int,
    rng: np.random.Generator,
    wind_times: np.ndarray,
    wind_values: np.ndarray,
    water_times: np.ndarray,
    water_values: np.ndarray,
    leaf_times: np.ndarray,
    leaf_values: np.ndarray,
    birds: list[tuple[float, float, float, float, float]],
    rustles: list[tuple[float, float, float]],
) -> np.ndarray:
    absolute_time = (start_frame + np.arange(frame_count, dtype=np.float64)) / SAMPLE_RATE

    # Broad, slowly moving wind with soft high-frequency air texture.
    wind_low = np.interp(absolute_time, wind_times, wind_values)
    wind_hiss = rng.standard_normal(frame_count) * 0.008
    wind = wind_low * 0.060 + wind_hiss

    # Very distant stream texture: quiet, smooth and intentionally unobtrusive.
    water_low = np.interp(absolute_time, water_times, water_values)
    water_mid = np.interp(absolute_time, leaf_times, leaf_values)
    water = water_low * 0.012 + water_mid * 0.003

    # Sparse moving leaves/rustling in the canopy.
    foliage = np.zeros(frame_count, dtype=np.float64)
    noise = rng.standard_normal(frame_count)
    chunk_start = start_frame / SAMPLE_RATE
    chunk_end = (start_frame + frame_count) / SAMPLE_RATE
    for event_start, duration, level in rustles:
        if event_start >= chunk_end or event_start + duration <= chunk_start:
            continue
        local_t = absolute_time - event_start
        active = (local_t >= 0.0) & (local_t <= duration)
        if np.any(active):
            phase = np.clip(local_t[active] / duration, 0.0, 1.0)
            envelope = np.sin(np.pi * phase) ** 1.6
            foliage[active] += noise[active] * envelope * level

    # Original tonal bird calls: short frequency-swept phrases at varied stereo positions.
    left_birds = np.zeros(frame_count, dtype=np.float64)
    right_birds = np.zeros(frame_count, dtype=np.float64)
    for event_start, duration, frequency, sweep, pan in birds:
        if event_start >= chunk_end or event_start + duration <= chunk_start:
            continue
        local_t = absolute_time - event_start
        active = (local_t >= 0.0) & (local_t <= duration)
        if not np.any(active):
            continue
        x = local_t[active]
        phase = TAU * (frequency * x + 0.5 * sweep * x * x)
        envelope = np.sin(np.pi * np.clip(x / duration, 0.0, 1.0)) ** 1.4
        tone = (np.sin(phase) + 0.20 * np.sin(phase * 2.03)) * envelope * 0.028
        left_birds[active] += tone * (1.0 - max(0.0, pan) * 0.45)
        right_birds[active] += tone * (1.0 + min(0.0, pan) * 0.45)

    # Slight natural stereo difference; no music, speech, or synthetic impacts.
    stereo_wind_l = wind * 0.94 + rng.standard_normal(frame_count) * 0.002
    stereo_wind_r = wind * 1.02 + rng.standard_normal(frame_count) * 0.002
    left = stereo_wind_l + water + foliage * 0.75 + left_birds
    right = stereo_wind_r + water * 0.97 + foliage * 0.88 + right_birds

    # Soft start/end fades avoid clicks if the source is previewed as a standalone master.
    fade_in = np.clip(absolute_time / 2.5, 0.0, 1.0)
    fade_out = np.clip((DURATION_SECONDS - absolute_time) / 3.0, 0.0, 1.0)
    fade = np.minimum(fade_in, fade_out)
    stereo = np.column_stack((left * fade, right * fade))
    return np.clip(stereo * 0.90, -0.92, 0.92)


def pack_int24(stereo: np.ndarray) -> bytes:
    values = np.rint(stereo * 8_388_607.0).astype(np.int32)
    packed = np.empty((values.shape[0], 2, 3), dtype=np.uint8)
    packed[:, :, 0] = values & 0xFF
    packed[:, :, 1] = (values >> 8) & 0xFF
    packed[:, :, 2] = (values >> 16) & 0xFF
    return packed.tobytes(order="C")


def main() -> None:
    rng = np.random.default_rng(19062026)
    OUTPUT.parent.mkdir(parents=True, exist_ok=True)

    # Slow control curves keep ambience organic without allocating the full master in RAM.
    wind_times = np.arange(0.0, DURATION_SECONDS + 3.0, 0.5)
    wind_values = rng.normal(0.0, 1.0, wind_times.size)
    water_times = np.arange(0.0, DURATION_SECONDS + 2.0, 0.12)
    water_values = rng.normal(0.0, 1.0, water_times.size)
    leaf_times = np.arange(0.0, DURATION_SECONDS + 2.0, 0.018)
    leaf_values = rng.normal(0.0, 1.0, leaf_times.size) * 0.45
    birds, rustles = make_events(rng)

    with wave.open(str(OUTPUT), "wb") as wav:
        wav.setnchannels(CHANNELS)
        wav.setsampwidth(SAMPLE_WIDTH)
        wav.setframerate(SAMPLE_RATE)
        total_frames = SAMPLE_RATE * DURATION_SECONDS
        chunk_frames = SAMPLE_RATE * CHUNK_SECONDS
        for start in range(0, total_frames, chunk_frames):
            count = min(chunk_frames, total_frames - start)
            rendered = render_chunk(
                start, count, rng,
                wind_times, wind_values,
                water_times, water_values,
                leaf_times, leaf_values,
                birds, rustles,
            )
            wav.writeframesraw(pack_int24(rendered))

    actual = OUTPUT.stat().st_size
    with wave.open(str(OUTPUT), "rb") as check:
        assert check.getnchannels() == CHANNELS
        assert check.getsampwidth() == SAMPLE_WIDTH
        assert check.getframerate() == SAMPLE_RATE
        assert check.getnframes() == SAMPLE_RATE * DURATION_SECONDS

    if actual <= 100 * 1024 * 1024:
        raise SystemExit(f"Source WAV is too small: {actual} bytes")
    if actual != EXPECTED_DATA_BYTES + 44:
        raise SystemExit(f"Unexpected WAV size: {actual} bytes")
    print(f"SOURCE_FILE={OUTPUT}")
    print(f"SOURCE_BYTES={actual}")
    print(f"SOURCE_MIB={actual / (1024 * 1024):.2f}")
    print(f"DURATION_SECONDS={DURATION_SECONDS}")
    print("FORMAT=48kHz stereo 24-bit PCM")
    print("CONTENT=original forest wind, canopy leaves, distant stream texture and birds")


if __name__ == "__main__":
    main()
