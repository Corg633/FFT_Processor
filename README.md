# FFT_Processor
Demo Code for FFT Processor with IP library modules (Quartus Pro)

# Specifications of Designed Platform

| **Parameter**         | **Value**             | **Formula / Note**                         |
|-----------------------|-----------------------|--------------------------------------------|
| ADC Resolution        | 12-bit                | SNR ≈ 74 dB (6.02N + 1.76)                 |
| Sampling Rate (fs)    | 10 MSPS               | Nyquist = 5 MHz                            |
| FFT Size (N)          | 8192-point            | Δf = fs / N = 1.22 kHz/bin                 |
| Total Bins            | 4096 usable bins      | N / 2 (Nyquist)                            |
| Output Magnitude      | 21-bit                | Enhanced dynamic range                     |
| FPGA ROM Capacity     | 16K                   | Limits FFT size to 8k-point                |

# Prerequisites

## Hardware:
- Intel MAX-10 10M50DAF484C7G FPGA Device
  50K Programmable Logic Elements
  1,638 Kbits M9K Memory
  5,888 Kbit User Flash Memory
  144 18×18 Multiplier
  4 PLLs

## Software: 
- Quartus Prime Lite 18.1

## Intellectual Property (IP) Library
IP (Intellectual Property) in FPGA/ASIC design refers to pre-designed, reusable
hardware modules that implement specific functions (e.g., FFTs, memory controllers, DSP
blocks). These are optimized for performance, power, and area, saving development time.

# Project's Description


## Modelsim (Testbench):

Illustration of Modelsim:
![FFT_testbench_200kHz](https://github.com/user-attachments/assets/fd5c9665-3e44-4d8e-b3ad-9a580d012d8a)

Illustration of Processing in MATLAB:
![vcd_parse_MATLAB](https://github.com/user-attachments/assets/56154bd6-f681-47fe-8e1f-955f735514ae)

## Single Tap (fft_hardware_adc):

Illustration of FPGA's output with 200kHz NCO generated signal:
![stp_tap_200kHz_NCO_high_rez](https://github.com/user-attachments/assets/88f1265d-ed15-4fbc-9b9e-0bb3fcf8a315)

SignalTap verification confirms correct 10MHz sampling timing, while the resistive
divider's ~0.27 attenuation ratio (56k/(56k+150k)) optimizes signal scaling. The design
demonstrates proper Nyquist compliance for audio-band analysis (20kHz bandwidth at
10MSPS), with the DC offset network enabling accurate bipolar signal acquisition using a
unipolar ADC.

![DE_Lite](https://github.com/user-attachments/assets/9aaab9d9-a9d5-4cc6-85b2-ec9aad44b18c)


Illustration of FPGA's output with ADC captured 20kHz signal:
![stp_tap_20kHz_ADC_high_rez](https://github.com/user-attachments/assets/9483a3a7-ceee-4df0-8810-bb16d9e92ac2)

## Final Processing and Comparison of captured signals in MATLAB:
![pn1](https://github.com/user-attachments/assets/7bad13b9-197a-4d14-9123-2f552fe7fdb5)

- **Spectrum Analyzer Result**: 
![Results_Labeled](https://github.com/user-attachments/assets/6ea141b5-61d7-4994-8d69-889b7e90ecb2)
  _Frequency resolution: spacing between FFT bins (e.g. 1.22 kHz/bin for 10 MSPS & 8192-point FFT)_
