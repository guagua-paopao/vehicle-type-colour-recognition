# Build Notes

How to build this, the order I built it in, and what I learned.

## Build and test

You'll need a Windows machine with an NVIDIA GPU, plus MSVC, Ninja, CUDA, TensorRT, OpenCV, Redis, PostgreSQL and vcpkg.

Change the paths to match your machine:

```powershell
powershell -ExecutionPolicy Bypass -File .\scripts\build_backend.ps1 `
  -VcpkgRoot D:\vcpkg `
  -CudaRoot D:\CUDA `
  -TensorRtRoot D:\TensorRT `
  -OpenCvDir D:\opencv\build\x64\vc16\lib

powershell -ExecutionPolicy Bypass -File .\scripts\test_all.ps1
```

The trained models and datasets aren't in this repo, so you'll need your own models before it can analyse video. The scripts I used for data prep and training are in `training/`.

## How I built it

I started from my people tracking project and kept the parts that had nothing to do with people, like the shared camera reader, task control, PostgreSQL storage, callbacks and monitoring. I wrote the vehicle logic as its own module and deleted the people-counting code once the vehicle version could replace it.

1. First I froze the baseline, the config and the event format.
2. Then I sorted out the data side: vehicle labels, labelling rules and a record of dataset licences.
3. I wrote common runners for the detection and attribute models, plus a registry to keep track of model versions.
4. Next came the main pipeline, which tracks vehicles, throws out bad pictures and combines several frames into one answer per vehicle.
5. After that I added storage and an API for vehicle events, snapshots, search and callbacks.
6. I set up automatic checks for performance, stability and rollback.
7. Then I trained the real models, exported them to ONNX and built them for TensorRT.
8. Finally I did three rounds of GPU optimisation, measuring after every change.

The detector only keeps the newest waiting frame for each camera so it doesn't fall behind, and type and colour recognition has its own limited queue so it can't hold up detection.

## What I learned

- A review of the first 600 priority samples threw out 379 as unrecognisable, and 3,254 auto-generated body-type labels were too unstable to train on, so I switched those off and kept the 810 reviewed ones.
- It only answers when it's confident, so about half of vehicles still end up as "unknown" for type by the end of their journey.
- Training and the C++ program have to prepare images in exactly the same way, so I matched them up and built the normalisation into the exported model.
- GPU video decoding saved about 21% of FFmpeg's CPU time, but live delay barely changed and memory went up by about 270 MB, so I left it off.
- After speeding things up I compared the outputs on 200 frames and 1,418 vehicle pictures and found no difference.
- The two ConvNeXt models now take about 54% of the time per frame, so any more speed would have to come from there.
