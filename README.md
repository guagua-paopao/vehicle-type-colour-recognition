# Vehicle Type and Colour Recognition from Camera Video

By Zichun Ai, MSc Internet of Things with AI, University of Bristol

This system watches traffic-camera video, finds each vehicle and follows it, then works out what type it is (sedan, SUV, van, bus, truck and so on) and what colour it is. Each vehicle ends up as one clean record, something like "a white SUV passed camera 1 at 14:02", with a snapshot.

It is my own learning version of the two-stage vehicle system I worked on during my machine-vision internship (May–Aug 2026).

## How it works

1. **Find the vehicles** in each frame.
2. **Follow each one** so the same car isn't counted twice.
3. **Pick the clearest picture** of it.
4. **Work out its type and colour** with two specialised AI models.
5. **Give one answer per vehicle** by combining several frames. If it still isn't sure, it says "unknown" instead of guessing.
6. **Save the record** and snapshot, ready to search or send to other systems.

## What it achieved

| | |
|---|---|
| **Time per frame** | 43.8 ms before optimisation, 17.9 ms after, using the same AI models |
| **Live video** | Keeps up with a 25 frames-per-second stream (24.8 FPS, up from 21.4) |
| **Top speed** | 21.9 FPS before, 39.7 FPS after, with no frame-rate limit |
| **Long run** | 45,000 frames over about 30 minutes, recovering from a forced video restart |
| **Finding vehicles** | Detection score (mAP50, where 1.0 is perfect): 0.75 on the general test set, 0.92 on the BMD-45 test set |
| **Type and colour** | About 93.5% correct when it gives an answer. It answers for about 80% of type checks and 75% of colour checks |

The speed-up comes from doing more of the image work on the GPU, copying less data around, and saving snapshots in the background. The answers stayed the same: checks on 200 frames and 1,418 vehicle pictures found no difference.

## Good to know

- The speed numbers come from my RTX 4080 laptop and a looped 60-second test video, not a live roadside camera.
- Vehicle type is the hardest part. Across a vehicle's whole journey through the scene, about half still end up as "unknown".
- The model files and datasets aren't in this repository, so the code can't be run on its own.
- This is a non-commercial learning project.

## Built with

C++ · CUDA · TensorRT · ONNX · YOLO11 · ConvNeXt · FFmpeg · OpenCV · PostgreSQL · Redis

Build steps and what I learned along the way are in [BUILD_NOTES.md](BUILD_NOTES.md).

## My other projects

- [people-flow-analysis](https://github.com/guagua-paopao/people-flow-analysis): people-flow analysis from live camera video
- [document-qa-assistant](https://github.com/guagua-paopao/document-qa-assistant): an AI assistant that answers questions from company documents
