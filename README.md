# Vehicle Type and Colour Recognition from Camera Video

By Zichun Ai, MSc Internet of Things with AI, University of Bristol

You give this traffic-camera video and it finds each vehicle, follows it, and works out what type it is (sedan, SUV, van, bus, truck and so on) and what colour it is. Each vehicle ends up as one clean record with a snapshot, something like "a white SUV passed camera 1 at 14:02".

It's my own learning version of the two-stage vehicle system I worked on during my machine-vision internship (May–Aug 2026).

## How it works

1. It finds the vehicles in each frame.
2. It follows each one so the same car doesn't get counted twice.
3. It picks the clearest picture of that vehicle.
4. Two AI models work out the type and the colour.
5. It combines several frames into one answer per vehicle, and says "unknown" if it still isn't sure.
6. It saves the record and the snapshot, ready to search or send to other systems.

## What it achieved

- Each frame used to take 43.8 ms and now takes 17.9 ms, with the same AI models.
- On a 25 frames-per-second live stream it now keeps up at 24.8 FPS, up from 21.4.
- With no frame-rate limit it went from 21.9 FPS to 39.7 FPS.
- It ran through 45,000 frames over about 30 minutes and recovered when I forced the video to restart.
- Its detection score (mAP50, where 1.0 is perfect) is 0.75 on the general test set and 0.92 on the BMD-45 test set.
- When it does give a type or colour it's right about 93.5% of the time, and it gives an answer for about 80% of type checks and 75% of colour checks.

The speed-up came from doing more of the image work on the GPU, copying less data around and saving snapshots in the background. I checked 200 frames and 1,418 vehicle pictures afterwards and the answers hadn't changed.

## Good to know

- The speed numbers are from my RTX 4080 laptop and a looped 60-second test video, so they aren't from a live roadside camera.
- Vehicle type is the hardest part, and about half of vehicles still end up as "unknown" by the end of their journey through the scene.
- The model files and datasets aren't in this repo, so you can't run the code on its own.
- This is a non-commercial learning project.

## Built with

C++ · CUDA · TensorRT · ONNX · YOLO11 · ConvNeXt · FFmpeg · OpenCV · PostgreSQL · Redis

Build steps and what I learned along the way are in [BUILD_NOTES.md](BUILD_NOTES.md).

## My other projects

- [people-flow-analysis](https://github.com/guagua-paopao/people-flow-analysis): people-flow analysis from live camera video
- [document-qa-assistant](https://github.com/guagua-paopao/document-qa-assistant): an AI assistant that answers questions from company documents
