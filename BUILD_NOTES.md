# Build Notes

How to build this project, how I put it together, and what I learned.

## Build and test

This project runs on Windows with an NVIDIA GPU. It needs Windows x64, MSVC, Ninja, CUDA, TensorRT, OpenCV, Redis, PostgreSQL and vcpkg.

Change the paths to match your machine:

```powershell
powershell -ExecutionPolicy Bypass -File .\scripts\build_backend.ps1 `
  -VcpkgRoot D:\vcpkg `
  -CudaRoot D:\CUDA `
  -TensorRtRoot D:\TensorRT `
  -OpenCvDir D:\opencv\build\x64\vc16\lib

powershell -ExecutionPolicy Bypass -File .\scripts\test_all.ps1
```

The trained models and the datasets are not in this repository, so the service needs your own models before it can analyse video. The scripts I used for data preparation and training are in `training/`.

## How I built it

I started from my people-flow project and kept the parts that were not specific to people: the shared camera reader, task control, PostgreSQL storage, callbacks and monitoring. The vehicle logic was built as its own module, and the people-counting code was removed once the vehicle version could replace it.

1. **Fix the starting point.** Freeze the baseline, the config and the event format.
2. **Data rules.** Define the vehicle labels, keep a record of dataset licences, and write labelling rules.
3. **Model interfaces.** Common runners for the detection and attribute models, and a registry of model versions.
4. **The main pipeline.** Track vehicles, reject poor pictures, and combine several frames into one answer per vehicle.
5. **Storage and API.** Vehicle events, snapshots, search and callbacks.
6. **Release checks.** Automatic checks for performance, stability and rollback.
7. **Real models.** Train the models, export them to ONNX and build them for TensorRT.
8. **Speed.** Three rounds of GPU optimisation, measuring after every change.

Two queues keep it running in real time. The detector only keeps the newest waiting frame for each camera, so it does not fall behind. Type and colour recognition has its own limited queue, which removes duplicates and prefers the best pictures, so slow classification cannot hold up detection.

## What I learned

- **Check the data before trusting it.** A review of the first 600 priority samples rejected 379 as unrecognisable. 3,254 body-type labels generated automatically by a vision-language model were too unstable to train on, so I switched them off and kept the 810 reviewed labels.
- **"Unknown" is a valid answer.** The system only answers when it is confident. The cost is real: across a vehicle's whole journey, about half still end up with an unknown type.
- **Training and deployment must prepare images the same way.** I matched colour order, resizing and input range between training and the C++ program, and built the normalisation into the exported model.
- **Measure before keeping an optimisation.** GPU video decoding cut FFmpeg's CPU time by about 21%, but live delay did not really improve and memory use rose by about 270 MB, because frames still had to be copied back from the GPU. I left it off.
- **Prove a speed-up did not change the results.** After optimising, I compared outputs on 200 frames and 1,418 vehicle pictures and found no difference.
- **The bottleneck moves.** After the optimisation work, the two ConvNeXt models take about 54% of the time per frame, so that is where further speed-ups would have to come from.
